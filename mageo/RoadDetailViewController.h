//
//  RoadDetailViewController.h
//  mageo
//
//  Created by swallow on 2/11/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoadDetailViewController : UIViewController{
}

@property (weak, nonatomic) IBOutlet UITableView *tableview_road;

@property (nonatomic,strong) NSMutableDictionary * table_road_data;

@end
