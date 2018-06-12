READ ME


I created a rough version of an instagram styled app for iOS using Firebase Database and Firebase Storage. In the app the user can view the 10 most recent posts with their corresponding descriptions as well create image posts and upload the post with a description.

There are some known bugs in the program:

- The refresh button is not implemented in the safest way. Manually calling viewDidLoad is not something that is recommended and is just a quick and dirty solution.
- On occasion the UI has issues where it does not correctly show the description of the post unless it calls cellForRow at again by scrolling past and then back to the post. 
- The app only shows the first ten and does not yet autoload older posts when the user scrolls to the bottom. 
- The app does not automatically refresh when the user posts and an image so the user has to manually click the refresh button.


None of these issues are detrimental and can easily be fixed if given more time to fix all the small UI problems.

If I was scaling this program to an actual audience I would not use the naming conventions in the database that I used but being that there is no login and is only going to be used by one device for testing now I did not feel it was too detrimental. Ideally each post would have a uid that would be created with the users uid and the date or something of that sort. This would also greatly change how I would have accessed the newest images in the database. The way I currently have it implemented works but is not truly scalable because if two images were posted at the same time it would most likely cause a lot of confusion to the database and app. 
