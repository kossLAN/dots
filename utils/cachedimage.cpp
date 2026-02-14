#include "cachedimage.h"

#include <QtCore/QCryptographicHash>
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QStandardPaths>
#include <QtNetwork/QNetworkRequest>

static QNetworkAccessManager* sNam = nullptr; // NOLINT

QNetworkAccessManager* CachedImage::nam() {
	if (!sNam) {
		sNam = new QNetworkAccessManager();
	}

	return sNam;
}

CachedImage::CachedImage(QObject* parent): QObject(parent) {
	mCacheDir =
	    QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + "/nixiutils/images";
}

CachedImage::~CachedImage() {
	if (mReply) {
		mReply->abort();
		mReply->deleteLater();
	}
}

QUrl CachedImage::source() const { return mSource; }

void CachedImage::setSource(const QUrl& source) {
	if (mSource == source) return;

	if (mReply) {
		mReply->abort();
		mReply->deleteLater();
		mReply = nullptr;
	}

	mSource = source;
	emit sourceChanged();

	mCachedSource = QUrl();
	mReady = false;
	emit cachedSourceChanged();
	emit readyChanged();

	if (mSource.isEmpty() || mSource.toString().isEmpty()) return;

	resolve();
}

QUrl CachedImage::cachedSource() const { return mCachedSource; }

bool CachedImage::ready() const { return mReady; }

QString CachedImage::cacheDir() const { return mCacheDir; }

void CachedImage::setCacheDir(const QString& cacheDir) {
	if (mCacheDir == cacheDir) return;
	mCacheDir = cacheDir;
	emit cacheDirChanged();
}

void CachedImage::resolve() {
	auto scheme = mSource.scheme();

	if (scheme == "file" || scheme.isEmpty()) {
		mCachedSource = mSource;
		mReady = true;
		emit cachedSourceChanged();
		emit readyChanged();
		return;
	}

	if (scheme == "http" || scheme == "https") {
		QString urlStr = mSource.toString().trimmed();
		QString sanitized;
		sanitized.reserve(urlStr.size());

		for (const auto& c: urlStr) {
			if (!c.isSpace()) sanitized.append(c);
		}

		auto hash = QCryptographicHash::hash(sanitized.toUtf8(), QCryptographicHash::Md5).toHex();
		mCachedPath = mCacheDir + "/" + QString::fromLatin1(hash) + ".jpg";

		if (QFileInfo::exists(mCachedPath)) {
			mCachedSource = QUrl::fromLocalFile(mCachedPath);
			mReady = true;
			emit cachedSourceChanged();
			emit readyChanged();
		} else {
			download();
		}
	}
}

void CachedImage::download() {
	QDir().mkpath(mCacheDir);

	QNetworkRequest request(mSource);
	request.setAttribute(
	    QNetworkRequest::RedirectPolicyAttribute,
	    QNetworkRequest::NoLessSafeRedirectPolicy
	);
	mReply = nam()->get(request);

	connect(mReply, &QNetworkReply::finished, this, [this]() {
		auto* reply = mReply;
		mReply = nullptr;

		if (!reply) return;
		reply->deleteLater();

		if (reply->error() != QNetworkReply::NoError) {
			if (reply->error() != QNetworkReply::OperationCanceledError) {
				qWarning() << "CachedImage: download failed:" << mSource << reply->errorString();
			}
			return;
		}

		QFile file(mCachedPath);
		if (!file.open(QIODevice::WriteOnly)) {
			qWarning() << "CachedImage: failed to write cache file:" << mCachedPath;
			return;
		}

		file.write(reply->readAll());
		file.close();

		mCachedSource = QUrl::fromLocalFile(mCachedPath);
		mReady = true;
		emit cachedSourceChanged();
		emit readyChanged();
	});
}
