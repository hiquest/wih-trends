# "Who Is Hiring" Trends
Take a look at current hiring trends at [Who Is Hiring Trends website](http://wih.mdnbar.com/).

# What Is This?
[Hacker News](https://news.ycombinator.com/) "Who Is Hiring" posts have always been a great way to find a job in IT. It also gives a broader look on the industry as a whole: what specialist are more in demand, what are less, what JavaScript frameworks are trending, does remote jobs grow, that sort of thing...

Here we are trying to analyse these posts and draw an overall "trends" picture.

# Usage
Prerequisites:
  `npm install -g coffee-script gulp`

Fetch and parse data from HN posts:
  `coffee grab_data.coffee > src/script/data.coffee`

Build and run site locally on port 8080:
  `gulp serve`

# Contributing
Feel free to fork, hack and send pull-requests.
