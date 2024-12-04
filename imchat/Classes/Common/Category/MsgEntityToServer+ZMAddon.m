//
//  MsgEntityToServer+ZMAddon.m
//  imchat
//
//  Created by Lilou on 2024/10/23.
//

#import "MsgEntityToServer+ZMAddon.h"

@implementation MsgEntityToServer (ZMAddon)

/*
- (CGFloat)msgHeight {
    return [self zm_Height];
//    return [objc_getAssociatedObject(self, @selector(msgHeight)) floatValue];
}

//- (void)setMsgHeight:(CGFloat)value {
//    objc_setAssociatedObject(self, @selector(msgHeight), @(value), OBJC_ASSOCIATION_ASSIGN);
//}


- (CGFloat)zm_Height{
    
    switch (self.msgType) {
        case MsgType_JoinServer:
            
            break;
        case MsgType_TextType:
            return [self textHeight];
            
        case MsgType_ImgType:
            
            return [self imageHeight];
        case MsgType_VideoType:
            
            return [self videoHeight];
        case MsgType_ReadStatus:
            
         
        case MsgType_InputStatus:
            
            
        default:
            break;
    }

    return 0.f;
}

- (CGFloat)textHeight{
    
    NSString *text = self.textMsg.text ?: @"";
    
    // fixed = 89;
    CGFloat h = 55;

    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);

    CGRect textRect = [text boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil];
    
    return h + textRect.size.height ;
    
}

- (CGFloat)imageHeight{
    
    NSString *text = self.textMsg.text ?: @"";
    
    // fixed = 89;
    CGFloat h = 55;

    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);

    CGRect textRect = [text boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil];
    
    return h + textRect.size.height ;
    
}

- (CGFloat)videoHeight{
    
    NSString *text = self.textMsg.text ?: @"";
    
    // fixed = 89;
    CGFloat h = 55;

    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};


    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);

    CGRect textRect = [text boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil];
    
    return h + textRect.size.height ;
    
}


// FAQ
//- (CGFloat)height{
//    // fixed = 89;
//    CGFloat h = 89 + 8;
//
//    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};
//
//
//    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);
//
//    CGRect textRect = [self.text boundingRectWithSize:maxSize
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:attributes
//                                          context:nil];
//    CGFloat faqBtnHeight = 5 * 30 ;
//
//    return h + textRect.size.height + faqBtnHeight;
//
//}

// Queue
//- (CGFloat)height{
//    // fixed = 89;
//    CGFloat h = 55;
//
//    NSDictionary *attributes = @{NSFontAttributeName: ZMFontRes.font_14};
//
//
//    CGSize maxSize = CGSizeMake(kW(246), CGFLOAT_MAX);
//
//    CGRect textRect = [self.text boundingRectWithSize:maxSize
//                                          options:NSStringDrawingUsesLineFragmentOrigin
//                                       attributes:attributes
//                                          context:nil];
//
//    return h + textRect.size.height ;
//}
 */
@end
