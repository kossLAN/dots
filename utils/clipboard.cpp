#include "clipboard.h"

#include <QtCore/QBuffer>
#include <QtCore/QByteArray>
#include <QtCore/QFile>
#include <QtCore/QMimeDatabase>
#include <QtGui/QClipboard>
#include <QtGui/QGuiApplication>

ClipboardUtils::ClipboardUtils(QObject* parent): QObject(parent) {}

QString ClipboardUtils::clipboardImage() const {
	QImage image =
	    static_cast<QGuiApplication*>(QGuiApplication::instance())->clipboard()->image(); // NOLINT

	if (image.isNull()) return QString();

	QByteArray byteArray;
	QBuffer buffer(&byteArray);
	buffer.open(QIODevice::WriteOnly);
	image.save(&buffer, "PNG");
	buffer.close();

	return QString::fromLatin1(byteArray.toBase64());
}

QString ClipboardUtils::fileToBase64(const QUrl& fileUrl) const {
	QString filePath = fileUrl.toLocalFile();
	QFile file(filePath);
	if (!file.open(QIODevice::ReadOnly)) return QString();

	QByteArray data = file.readAll();
	file.close();

	return QString::fromLatin1(data.toBase64());
}

QString ClipboardUtils::getMimeType(const QUrl& fileUrl) const {
	QString filePath = fileUrl.toLocalFile();
	QMimeDatabase db;
	return db.mimeTypeForFile(filePath).name();
}
