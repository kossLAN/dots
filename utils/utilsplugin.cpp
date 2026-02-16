#include "utilsplugin.h"

#include <QtQml>

#include "cachedimage.h"
#include "clipboard.h"
#include "latexrenderer.h"

void UtilsPlugin::registerTypes(const char* uri) {
	qmlRegisterSingletonType<ClipboardUtils>(
	    uri,
	    1,
	    0,
	    "NixiUtils",
	    [](QQmlEngine* engine, QJSEngine* scriptEngine) -> QObject* {
		    Q_UNUSED(engine)
		    Q_UNUSED(scriptEngine)
		    return new ClipboardUtils();
	    }
	);

	qmlRegisterType<CachedImage>(uri, 1, 0, "CachedImage");
	qmlRegisterType<LatexRenderer>(uri, 1, 0, "LatexRenderer");
}
