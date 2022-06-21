//
//  MovieViewController.m
//  Flixter
//
//  Created by Onwuosiuno Ikhioda on 6/15/22.
//

#import "MovieViewController.h"
#import "customCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MovieViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.activityIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=cb02447945bd8b38db35a1609e415b14"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error loading movies"
                                              message:@"There is no network connection"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action) {}];
                
               [alert addAction:defaultAction];
               [self presentViewController:alert animated:YES completion:nil];
           }
           else {
               [self.activityIndicator stopAnimating];
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//               NSLog(@"%@", dataDictionary);
               NSArray *moviesArray = dataDictionary[@"results"];
               self.movies = moviesArray;
               for (NSDictionary *movies in self.movies)
               {
                   NSLog(@"%@", movies);
                   
               }
               

               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
               [self.tableView reloadData];
           }
       }];
    [task resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    DetailsViewController *viewController = segue.destinationViewController;
    NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
    viewController.movie = self.movies[indexpath.row];
    
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    return [[UITableViewCell alloc] init];
    customCell *cell = [ tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
    cell.info.text = self.movies[indexPath.row][@"overview"];
    cell.info.font = [cell.info.font fontWithSize:12];
    cell.info.lineBreakMode = NSLineBreakByWordWrapping;
    cell.info.numberOfLines = 0;
    
    cell.title.text = self.movies[indexPath.row][@"title"];
//    [cell.poster setImageWithURL: self.movies[@"poster_path"]];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.movies[indexPath.row][@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString: posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [cell.poster setImageWithURL:posterURL];
    
    
    

//    cell.poster
    return cell;
}

@end

