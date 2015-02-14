//
//  GmapAnnotationView.h
//  mageo
//
//  Created by swallow on 2/10/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DisclosureTappedBlock)();

@interface GmapAnnotationView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imgview_photo;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subject;
@property (weak, nonatomic) IBOutlet UILabel *lbl_latitude;
@property (weak, nonatomic) IBOutlet UILabel *lbl_longitude;

@property (weak, nonatomic) IBOutlet UIButton *btn_disclosure;

- (IBAction)on_click_btn_disclosure:(id)sender;

@property (nonatomic,copy) DisclosureTappedBlock onDisclosureTappedBlock;

- (void)initialize;

@end
