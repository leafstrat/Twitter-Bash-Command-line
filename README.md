# Twitter Bash Command-line

This command-line tool allows you to navigate and interact with Twitter from your terminal.

**! ! ! Warning:** messy code 🤪

Made this for myself to make using Twitter more enjoyable for me. I like doing things over the command-line if I can, very fast, responsive, and not requiring a mouse is preferable to me.

This Bash script is using the undocumented API so things on Twitter's end are prone to change frequently destroying most usability in the script. It will require me to find  these new changes and modify the script to reflect them in order to keep working. This is not recommended to use if you aren't comfortable with Bash so you can make your own changes and updates when things break.

### Requirements:
GNU core utilities: sed, cut, grep - etc

```
sudo apt-get install bash curl jq
```

### Adding account data:
1. Create a textfile in /accounts/ named after your Twitter username
2. Copy the contents of the `template` file into your username file
3. Fill in the details by logging in to your account on Twitter and browsing the Network Tools tab
4. On first run it will ask you to choose one of your accounts

### Features:
- Tweet searching
- Tweet search next page navigation
- Refresh Tweet search and home feed
- Reply to a Tweet from search or home feed
- Like a Tweet from search or home feed
- Follow user from search results
- View home feed, latest Tweets
- View notifications
- See notification count during all interactions
- Keep track of all advertisements targeted to you
- Save list of all accounts you've followed

### TODO:
- [ ] Next page home feed
- [ ] Send a tweet
- [ ] Account switching
- [ ] Save your frequent searches 
- [ ] Direct messaging capabilities
- [ ] Prevent ads displaying in search results
- [ ] Prevent ads displaying in homepage feeds
- [ ] View a tweet conversation
- [ ] Display Twitter topics
- [ ] Lookup user and print profile data
- [ ] Notifications - handle a retweet
- [ ] Notifications - deal with multiple people liking a tweet
- [ ] Unfollow accounts not following you back from your follow list after a certain threshold of days
- [ ] Mute an account from your homepage
- [ ] Modify search query arguments ie: -filter:links
- [ ] Delete direcrt message
- [ ] showme         : reports the raw information of yourself.
- [ ] whoami         : reports the screen name of yourself.
