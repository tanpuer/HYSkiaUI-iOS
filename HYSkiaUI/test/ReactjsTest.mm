#include "ReactjsTest.h"

namespace HYSkiaUI {

void ReactjsTest::doDrawTest(int drawCount, SkCanvas *canvas, int width, int height) {
    if (!createFlag) {
        createFlag = true;
//        auto jsBuffer = context->getAssetManager()->readFile("test.js");
        auto jsBuffer = context->getAssetManager()->readFile("react_bundle.js");
        jsCoreRuntime->evaluateJavaScript(jsBuffer);
    }
    performAnimations(width, height);
    jsCoreRuntime->invokeFrameCallback();
    context->getPageStackManager()->removeDestroyedPage();
    for (const auto &item: context->getPageStackManager()->getPages()) {
        if (!item->getVisibility()) {
            continue;
        }
        item->drawOneFrame(drawCount);
        item->measure();
        item->layout(0, 0, width, height);
        item->draw(canvas);
    }
}

void ReactjsTest::setContext(std::shared_ptr<SkiaUIContext>& context) {
    ITestDraw::setContext(context);
    JSSkiaUIContext::getInstance()->setUIContext(context);
    jsCoreRuntime = std::make_unique<JSCoreRuntime>(context);
}

}

