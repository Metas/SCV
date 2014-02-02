//
//  SPVViewController.h
//  ScavaPhotoView
//
//  Created by Shruti on 1/30/14.
//  Copyright (c) 2014 Shruti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPVViewController : UIViewController < NSURLConnectionDataDelegate>
{
    NSString *flikrURL;
    NSString *searchText;

    NSMutableArray *flikrLargePhotoURL;
    int rowNumber;
    int pageNumber ;
}
@property (strong,readwrite)NSString *flikrURL;
@property (strong,readwrite)NSString *searchText ;

-(void)searchFlikrPhotos;


@property (weak, nonatomic) IBOutlet UIImageView *FlikrImage;
@property (strong, nonatomic) IBOutlet UITableView *flikrTable;

@end
