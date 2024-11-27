#include "HYSkiaUIApp.hpp"
#import <include/core/SkPictureRecorder.h>
#import <include/core/SkCanvas.h>
#import <include/core/SkPaint.h>
#include "CppTest.h"

HYSkiaUIApp::HYSkiaUIApp(int width, int height, NSThread *skiaUIThread) {
    _width = width;
    _height = height;
    _context = std::make_shared<SkiaUIContext>(skiaUIThread);
    testDraw = std::make_unique<CppTest>();
    testDraw->setContext(_context);
}

HYSkiaUIApp::~HYSkiaUIApp() {
    
}

SkPicture* HYSkiaUIApp::doFrame(long time) {
    IAnimator::currTime = time;
    _context->setTimeMills(time);
    SkPictureRecorder recorder;
    auto recordingCanvas = recorder.beginRecording(_width, _height);
    testDraw->doDrawTest(drawCount, recordingCanvas, _width, _height);
    auto picture = recorder.finishRecordingAsPicture();
    picture->ref();
    return picture.get();
}

void HYSkiaUIApp::dispatchTouchEvent(TouchEvent *touchEvent) {
    mTouchEvent = std::unique_ptr<TouchEvent>(touchEvent);
    auto page = _context->getPageStackManager()->back();
    if (page) {
        page->dispatchTouchEvent(mTouchEvent.get());
    }
}

void HYSkiaUIApp::setVelocity(float x, float y) {
    auto velocity = new Velocity(x, y);
    auto page = _context->getPageStackManager()->back();
    if (page) {
        page->dispatchVelocity(velocity);
    }
}

void HYSkiaUIApp::onBackPressed(float distance) {
    if (_context->getPageStackManager()->getPages().size() <= 1) {
        return;
    }
    if (distance > 100) {
        auto page = _context->getPageStackManager()->back();
        if (page != nullptr) {
            page->exitToLeft(Page::EnterExitInfo(page->animTranslateX, _width));
        }
    } else {
        auto page = _context->getPageStackManager()->back();
        if (page != nullptr) {
            page->enterFromRight(Page::EnterExitInfo(page->animTranslateX, 0));
        }
    }
}

void HYSkiaUIApp::onBackMoved(float distance) {
    if (_context->getPageStackManager()->getPages().size() <= 1) {
        return;
    }
    auto page = _context->getPageStackManager()->back();
    page->animTranslateX = distance;
    auto size = _context->getPageStackManager()->getPages().size();
    auto prePage = _context->getPageStackManager()->getPages()[size - 2];
    prePage->setVisibility(true);
}
