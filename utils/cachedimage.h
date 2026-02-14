#ifndef CACHEDIMAGE_H
#define CACHEDIMAGE_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>

class CachedImage: public QObject {
	Q_OBJECT
	Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
	Q_PROPERTY(QUrl cachedSource READ cachedSource NOTIFY cachedSourceChanged)
	Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
	Q_PROPERTY(QString cacheDir READ cacheDir WRITE setCacheDir NOTIFY cacheDirChanged)

public:
	explicit CachedImage(QObject* parent = nullptr);
	CachedImage(const CachedImage&) = delete;
	CachedImage(CachedImage&&) = delete;
	CachedImage& operator=(const CachedImage&) = delete;
	CachedImage& operator=(CachedImage&&) = delete;
	CachedImage(QUrl mSource, QUrl mCachedSource, QString mCacheDir, QString mCachedPath)
	    : mSource(std::move(mSource))
	    , mCachedSource(std::move(mCachedSource))
	    , mCacheDir(std::move(mCacheDir))
	    , mCachedPath(std::move(mCachedPath)) {}
	~CachedImage() override;

	[[nodiscard]] QUrl source() const;
	void setSource(const QUrl& source);

	[[nodiscard]] QUrl cachedSource() const;
	[[nodiscard]] bool ready() const;

	[[nodiscard]] QString cacheDir() const;
	void setCacheDir(const QString& cacheDir);

signals:
	void sourceChanged();
	void cachedSourceChanged();
	void readyChanged();
	void cacheDirChanged();

private:
	void resolve();
	void download();

	static QNetworkAccessManager* nam();

	QUrl mSource;
	QUrl mCachedSource;
	bool mReady = false;
	QString mCacheDir;
	QString mCachedPath;
	QNetworkReply* mReply = nullptr;
};

#endif // CACHEDIMAGE_H
