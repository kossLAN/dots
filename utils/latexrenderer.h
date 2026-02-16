#ifndef LATEXRENDERER_H
#define LATEXRENDERER_H

#include <QtCore/QString>
#include <QtGui/QColor>
#include <QtQuick/QQuickPaintedItem>

namespace tex {
class TeXRender;
}

class LatexRenderer: public QQuickPaintedItem {
	Q_OBJECT
	Q_PROPERTY(QString formula READ formula WRITE setFormula NOTIFY formulaChanged)
	Q_PROPERTY(qreal fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
	Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

public:
	explicit LatexRenderer(QQuickItem* parent = nullptr);
	LatexRenderer(const LatexRenderer&) = delete;
	LatexRenderer(LatexRenderer&&) = delete;
	LatexRenderer& operator=(const LatexRenderer&) = delete;
	LatexRenderer& operator=(LatexRenderer&&) = delete;
	explicit LatexRenderer(QString mFormula): mFormula(std::move(mFormula)) {}
	~LatexRenderer() override;

	void paint(QPainter* painter) override;

	[[nodiscard]] QString formula() const;
	void setFormula(const QString& formula);

	[[nodiscard]] qreal fontSize() const;
	void setFontSize(qreal size);

	[[nodiscard]] QColor color() const;
	void setColor(const QColor& color);

signals:
	void formulaChanged();
	void fontSizeChanged();
	void colorChanged();

private:
	static void ensureInit();
	void updateRender();

	QString mFormula;
	qreal mFontSize = 16.0;
	QColor mColor = Qt::white;
	tex::TeXRender* mRender = nullptr;
};

#endif // LATEXRENDERER_H
