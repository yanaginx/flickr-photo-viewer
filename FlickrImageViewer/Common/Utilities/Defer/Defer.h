//
//  Defer.h
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#ifndef Defer_h
#define Defer_h

#define pspdf_defer_block_name_with_prefix(prefix, suffix) prefix ## suffix
#define pspdf_defer_block_name(suffix) pspdf_defer_block_name_with_prefix(pspdf_defer_, suffix)
#define pspdf_defer __strong void(^pspdf_defer_block_name(__LINE__))(void) __attribute__((cleanup(pspdf_defer_cleanup_block), unused)) = ^
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void pspdf_defer_cleanup_block(__strong void(^_Nullable * _Nullable block)(void)) {
    (*block)();
}
#pragma clang diagnostic pop

#endif /* Defer_h */
