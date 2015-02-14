//
//  RoadDetailViewController.m
//  mageo
//
//  Created by swallow on 2/11/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "RoadDetailViewController.h"
#import "NSDictionary+MetadataDatasource.h"

@interface RoadDetailViewController ()

@end

@implementation RoadDetailViewController

@synthesize tableview_road, table_road_data;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableview_road.delegate = table_road_data;
    self.tableview_road.dataSource = table_road_data;
    self.tableview_road.rowHeight = 25;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
