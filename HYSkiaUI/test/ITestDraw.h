#pragma once

#include "core/SkCanvas.h"
#include "FlexboxLayout.h"
#include "Page.h"

namespace HYSkiaUI {

class ITestDraw {
    
public:
    
    ITestDraw() {};
    
    virtual ~ITestDraw() {
        delete root;
    };
    
    virtual void performAnimations(int width, int height) {
        for (const auto &item: context->getPageStackManager()->getPages()) {
            if (item->getWidth() != width || item->getHeight() != height) {
                item->setWidth(width);
                item->setHeight(height);
            }
            item->performAnimations();
        }
    }
    
    virtual void doDrawTest(int drawCount, SkCanvas *canvas, int width, int height) = 0;
    
    virtual void setContext(std::shared_ptr<SkiaUIContext> context) {
        this->context = context;
    }
    
    virtual std::shared_ptr<SkiaUIContext> &getContext() {
        return context;
    }
    
    virtual void onShow() {
        context->getPageStackManager()->showCurrentPage();
    }
    
    virtual void onHide() {
        context->getPageStackManager()->hideCurrentPage();
    }
    
protected:
    
    Page *root = nullptr;
    
    std::shared_ptr<SkiaUIContext> context = nullptr;
    
};

}
