//
//  SPVViewController.m
//  ScavaPhotoView
//
//  Created by Shruti on 1/30/14.
//  Copyright (c) 2014 Shruti. All rights reserved.
//

#import "SPVViewController.h"
#import "SPVAppDelegate.h"
#import "SPVCell.h"

@interface SPVViewController ()
{
    NSMutableArray *imageArray;
}
@end

@implementation SPVViewController
@synthesize flikrURL;
@synthesize searchText;
@synthesize flikrTable;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    rowNumber =0;
    pageNumber =1;
   [self setSearchText:@"flower"];
    
    //initialize arrays
    flikrLargePhotoURL =[[NSMutableArray alloc]init];
    
    //add gesture recognizing
    UISwipeGestureRecognizer* gestureR;
    UISwipeGestureRecognizer* gestureL;
    gestureR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    gestureR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.flikrTable addGestureRecognizer:gestureR];
    
    gestureL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)] ;
    gestureL.direction = UISwipeGestureRecognizerDirectionLeft; // default
    [self.flikrTable addGestureRecognizer:gestureL];
    [self searchFlikrPhotos];
    
}

-(void)searchFlikrPhotos
{
    SPVAppDelegate *appDelegate =(SPVAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setFlikrURL:[NSString stringWithFormat:
                       @"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=5&page=%d&format=json&nojsoncallback=1",appDelegate.flikrAPIKey ,searchText,pageNumber]];
    NSURL *url =[[NSURL alloc]initWithString:flikrURL];
    NSURLRequest *request =[[NSURLRequest alloc]initWithURL:url];
    NSURLConnection *connection =[[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(connection)
    {
        NSLog(@"FLIKR CONNECTION SUCCESSFUL");
    }

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *jsonErr;
    NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonErr];
    
    NSArray *photos =[[dict objectForKey:@"photos"]objectForKey:@"photo"];
    for(NSDictionary *photo in photos)
    {

        NSString *photoURLString =
        [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg",
         [photo objectForKey:@"farm"], [photo objectForKey:@"server"],
         [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        [flikrLargePhotoURL addObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURLString]]];
        
    }
    [flikrTable reloadData];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"FLIKR RECIEVING RESPONSE");
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"FLIKR ERROR: %@",error);
}
-(void)handleSwipeRight:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(rowNumber >0)
            rowNumber =rowNumber-1;
        else
            rowNumber =0;
        [flikrTable reloadData];
        }
    
}
-(void)handleSwipeLeft:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        rowNumber = rowNumber+1;
        if(rowNumber <500)
        {
            [flikrTable reloadData];
            int reloadPoint = flikrLargePhotoURL.count-10;
            if(rowNumber >reloadPoint)//get more
            {
                pageNumber =pageNumber+1;
//                dispatch_queue_t reloadQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//                dispatch_async(reloadQ, ^{
                    [self searchFlikrPhotos];
//                });
                
            }
        }
        else
        {
            NSLog(@"MORE THAN 500 ");
        }
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

#pragma -TableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPVCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"flikrCell"];
    NSData *imageData ;
    if(flikrLargePhotoURL.count>0)
    {
        if(rowNumber <0)
            imageData  = [flikrLargePhotoURL objectAtIndex:0];
        //else if(rowNumber >100)//reload again
        else if(rowNumber < [flikrLargePhotoURL count])
            imageData = [flikrLargePhotoURL objectAtIndex:rowNumber];
        else
        {
            //reload
            [self searchFlikrPhotos];
            imageData = [flikrLargePhotoURL objectAtIndex:rowNumber];
        }
        
    }
        cell.imageView.image = [UIImage imageWithData:imageData];

    return cell;
}


@end
