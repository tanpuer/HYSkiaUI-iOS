#pragma once

struct ImageData {
    const char *content;
    long length;
    
    ~ImageData() {
        content = nullptr;
    }
};

class AssetManager {
    
public:
    
    AssetManager();
    
    char *readFile(const char *path);
    
    ImageData *readImage(const char *path);
    
    ImageData *readImage(const char *name, const char *type, const char *dir);
    
    bool exist(const char *path);
    
};
