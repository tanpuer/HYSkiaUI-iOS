#include "CppTest.h"
#include "Page.h"
#include "PageStackManager.h"
#include "ExamplePage.h"

void CppTest::doDrawTest(int drawCount, SkCanvas *canvas, int width, int height) {
    if (root == nullptr) {
        ALOGD("doDrawTest %d %d", width, height)
        auto page = new ExamplePage();
        root = page;
        page->init(context, width, height);
        context->getPageStackManager()->push(page);
        page->enterFromRight(Page::EnterExitInfo(width, 0));
    }
    if (root->getWidth() != width || root->getHeight() != height) {
        root->pageSizeChange(width, height);
    }
    performAnimations(width, height);
    context->getPageStackManager()->removeDestroyedPage();
    for (const auto &item: context->getPageStackManager()->getPages()) {
        if (!item->getVisibility()) {
            continue;
        }
        item->drawOnFrame(drawCount);
        item->measure();
        item->layout(0, 0, width, height);
        item->draw(canvas);
    }
}