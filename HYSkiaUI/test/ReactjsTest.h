#pragma once

#include "ITestDraw.h"
#include "JSCoreRuntime.h"
#include "JSSkiaUIContext.h"

namespace HYSkiaUI {

class ReactjsTest : public ITestDraw {

public:

    ReactjsTest() = default;

    ~ReactjsTest() {
        auto page = context->getPageStackManager()->back();
        delete page;
    }

    void doDrawTest(int drawCount, SkCanvas *canvas, int width, int height) override;
    
    void setContext(std::shared_ptr<SkiaUIContext>& context) override;

private:

    bool createFlag = false;
    
    std::unique_ptr<JSCoreRuntime> jsCoreRuntime = nullptr;

};

}

