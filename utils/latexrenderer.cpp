#include "latexrenderer.h"

#include <QPainter>
#include <QtCore/QDir>
#include <microtex/latex.h>
#include <microtex/platform/qt/graphic_qt.h>

static bool sInitialized = false; // NOLINT

void LatexRenderer::ensureInit() {
	if (sInitialized) return;

	QString resDir = qEnvironmentVariable("MICROTEX_RES_DIR");
	if (resDir.isEmpty()) {
#ifdef MICROTEX_RES_DIR
		resDir = QStringLiteral(MICROTEX_RES_DIR);
#endif
	}

	if (resDir.isEmpty() || !QDir(resDir).exists()) {
		qWarning() << "LatexRenderer: MicroTeX resource directory not found:" << resDir;
		return;
	}

	try {
		tex::LaTeX::init(resDir.toStdString());
		sInitialized = true;
	} catch (const std::exception& e) {
		qWarning() << "LatexRenderer: MicroTeX init failed:" << e.what();
	}
}

LatexRenderer::LatexRenderer(QQuickItem* parent): QQuickPaintedItem(parent) {
	ensureInit();
	setAntialiasing(true);
}

LatexRenderer::~LatexRenderer() { delete mRender; }

QString LatexRenderer::formula() const { return mFormula; }

void LatexRenderer::setFormula(const QString& formula) {
	if (mFormula == formula) return;
	mFormula = formula;
	emit formulaChanged();
	updateRender();
}

qreal LatexRenderer::fontSize() const { return mFontSize; }

void LatexRenderer::setFontSize(qreal size) {
	if (qFuzzyCompare(mFontSize, size)) return;
	mFontSize = size;
	emit fontSizeChanged();
	updateRender();
}

QColor LatexRenderer::color() const { return mColor; }

void LatexRenderer::setColor(const QColor& color) {
	if (mColor == color) return;
	mColor = color;
	emit colorChanged();
	updateRender();
}

void LatexRenderer::updateRender() {
	delete mRender;
	mRender = nullptr;

	if (mFormula.isEmpty() || !sInitialized) {
		setImplicitWidth(0);
		setImplicitHeight(0);
		update();
		return;
	}

	auto argb = static_cast<tex::color>(
	    (mColor.alpha() << 24) | (mColor.red() << 16) | (mColor.green() << 8) | mColor.blue()
	);

	try {
		mRender = tex::LaTeX::parse(
		    mFormula.toStdWString(),
		    0, // no line wrapping
		    static_cast<float>(mFontSize),
		    static_cast<float>(mFontSize / 3.0),
		    argb
		);
	} catch (const std::exception& e) {
		qWarning() << "LatexRenderer: parse error:" << e.what();
		mRender = nullptr;
	}

	if (mRender) {
		setImplicitWidth(mRender->getWidth());
		setImplicitHeight(mRender->getHeight() + mRender->getDepth());
	} else {
		setImplicitWidth(0);
		setImplicitHeight(0);
	}

	update();
}

void LatexRenderer::paint(QPainter* painter) {
	if (!mRender) return;

	painter->setRenderHint(QPainter::Antialiasing, true);
	painter->setRenderHint(QPainter::SmoothPixmapTransform, true);

	tex::Graphics2D_qt g2(painter);
	mRender->draw(g2, 0, 0);
}
