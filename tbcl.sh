#!/bin/bash
clear

## https://superuser.com/questions/1713969/how-to-put-colors-in-terminal
colprint() (
   text="${1#'[#'??????']'}"
   r="${1%"$text"}"
   r="${r%']'}"
   r="${r#'[#'}"
   r="${r:-FFFFFF}"
   b="${r#????}"
   r="${r%??}"
   g="${r#??}"
   r="${r%??}"
   printf '\e[38;2;%d;%d;%dm%s' "0x$r" "0x$g" "0x$b" "$text"
)

select_color() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}

colorsA=("#cf2a2a" "#d73c3c" "#dc5151" "#e06666" "#e47b7b" "#e99090" "#eda6a6" "#f28c23" "#f3993b" "#f5a553" "#f6b26b" "#f7bf83" "#f9cb9b" "#fad8b3" "#ffc61a" "#ffcc33" "#ffd34d" "#ffd966" "#ffdf80" "#ffe699" "#ffecb3" "#a44c7a" "#b25887" "#ba6a93" "#c27ba0" "#ca8cad" "#d29eb9" "#daafc6" "#d2190b" "#ea1c0d" "#f32c1e" "#f44336" "#f55a4e" "#f77066" "#f8877f" "#824f00" "#9b5f00" "#b56e00" "#ce7e00" "#e88e00" "#ff9d02" "#ffa71c")

colorsB=( "#69a84c" "#76b45a" "#84bc6b" "#93c47d" "#a2cc8f" "#b0d4a0" "#bfdcb2" "#634ca6" "#7059b3" "#7f6bbb" "#8e7cc3" "#9d8dcb" "#ac9fd3" "#bbb0db" "#3283cd" "#468fd2" "#5a9cd7" "#6fa8dc" "#84b4e1" "#98c1e6" "#adcdeb" "#507f89" "#598e99" "#669aa6" "#76a5af" "#86b0b8" "#96bac2" "#a6c5cb" "#1c5c8c" "#206aa2" "#2578b7" "#2986cc" "#3892d7" "#4d9edb" "#62aadf" "#5a8200" "#6c9b00" "#7db500" "#8fce00" "#a1e800" "#b2ff02" "#b9ff1c")

RESET="\033[0m"
BOLD="\033[1m"
GREEN="\e[32m"
RED="\e[31m"

# FUNC tips
function tips () {
clear
echo "
Notifications:		n 		*WIP* shows notifications
Switch Account:		sw		choose from account to switch to
Next page:		np		next page results from search
Homepage:		h 		*WIP* shows homepage chronological feed 
Refresh:		r		refreshes last search
Inbox:			i 		*WIP* shows DM inbox
Liking:			l 1,2		likes post #1 and #2
Search:			s linux		searches for linux
Follow:			f 1,2		follows user #1 and #2
Profile:		p 13 		*WIP* displays user #13 profile in terminal
Open:			o 12		opens user #12 in browser
Message:		dm 9		*WIP* direct messages user #9
Reply:			9 hey		replying to post #9
"
}
# FUNC ProgressBar
function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
	printf "\r${BOLD}loading ${command}${RESET} [${_fill// /${GREEN}#${RESET}}${_empty// /-}] ${_progress}%% "
}


function get_variables () {
cookie_query=$(cat accounts/$username | grep "Cookie:")
[ -z "$cookie_query" ] && echo "Cookie is empty for $username, exiting" && exit

token_query=$(cat accounts/$username | grep "x-csrf-token:")
authorization_query=$(cat accounts/$username | grep "authorization:")
user_agent=$(cat accounts/$username | grep "User-Agent:")

FavoriteTweet=$(cat accounts/$username | grep "/FavoriteTweet")
CreateTweet=$(cat accounts/$username | grep "/CreateTweet")
HomeLatestTimeline=$(cat accounts/$username | grep "/HomeLatestTimeline")
tweet_create_query_ID=$(cat accounts/$username | grep "/CreateTweet" | cut -d'/' -f1)

}

# FUNC SwitchAccount
##------------------------------------------------
##                     _ __       __                                         __ 
##      ______      __(_) /______/ /_     ____ _______________  __  ______  / /_
##     / ___/ | /| / / / __/ ___/ __ \   / __ `/ ___/ ___/ __ \/ / / / __ \/ __/
##    (__  )| |/ |/ / / /_/ /__/ / / /  / /_/ / /__/ /__/ /_/ / /_/ / / / / /_  
##   /____/ |__/|__/_/\__/\___/_/ /_/   \__,_/\___/\___/\____/\__,_/_/ /_/\__/  
##                                                                              
##------------------------------------------------

## rm these files on account switch .search_cursor_bottom .last_search_query .ads.json
function SwitchAccount () {
rm .search_cursor_bottom .last_search_query .ads.json 2> /dev/null
line_count=0
clear
echo -e "${BOLD}Choose Account${RESET}\n"

accounts=$(ls accounts/* | grep -v template)
while read -r line; do
	line_count=$[$line_count +1]
	echo "[$line_count] $(echo "$line" | cut -d '/' -f2)"
done <<< "$accounts"

echo ""
read -p -r -ep "$(echo -e $BOLD)@$username > $(echo -e $RESET)" switch_account

username=$(sed -n ${switch_account}p <<< "$accounts" | cut -d '/' -f2)
get_variables
echo "$username" > .current_account
}



## prompt user to choose account on first run (.current_account is empty)
if [ -s .current_account ]
then
	username=$(cat .current_account)
	get_variables
else
    SwitchAccount
	get_variables
fi




# FUNC todo
##------------------
##       __            __    
##      / /_____  ____/ /___ 
##     / __/ __ \/ __  / __ \
##    / /_/ /_/ / /_/ / /_/ /
##    \__/\____/\__,_/\____/ 
##                           
##------------------

## direct all rm output to stdin so first runs dont display errrors

## twitter topics
## https://inboundfound.com/twitter-topics-list/#mega-list

## find features here:
## https://pypi.org/project/twitter-api-client/







# FUNC notifications_alert
function notifications_alert () {
notifications_response=$(curl -s 'https://twitter.com/i/api/2/badge_count/badge_count.json?supports_ntab_urt=1' \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Referer: https://twitter.com/notifications' \
-H 'x-twitter-polling: true' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Origin: https://twitter.com' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
-H 'TE: trailers' --compressed | jq -r '"\(.ntab_unread_count)|\(.dm_unread_count)"')
}



# FUNC follow
##------------------------
##       ____      ____             
##      / __/___  / / /___ _      __
##     / /_/ __ \/ / / __ \ | /| / /
##    / __/ /_/ / / / /_/ / |/ |/ / 
##   /_/  \____/_/_/\____/|__/|__/  
##                                  
##------------------------
function follow () {

date_string=$(date "+%m-%d-%Y")
follow_array=( $strings )
for i in "${follow_array[@]}"
do



variables_query='include_profile_interstitial_type=1&include_blocking=1&include_blocked_by=1&include_followed_by=1&include_want_retweets=1&include_mute_edge=1&include_can_dm=1&include_can_media_tag=1&include_ext_has_nft_avatar=1&include_ext_is_blue_verified=1&include_ext_verified_type=1&include_ext_profile_image_shape=1&skip_status=1&user_id='$i''

follow_response=$(curl -s 'https://twitter.com/i/api/1.1/friendships/create.json' -X POST \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
--data-raw "$(echo "$variables_query" | sed 's/\n//g')" --compressed | jq -r '{user_id: .id_str, name: .name, screen_name: .screen_name|tostring, action: .following|tostring} | join("|")')

follow_id=$(echo "$follow_response" | cut -d '|' -f1)
follow_name=$(echo "$follow_response" | cut -d '|' -f2)
follow_screen_name=$(echo "$follow_response" | cut -d '|' -f3)
follow_action=$(echo "$follow_response" | cut -d '|' -f4)

if [[ "$follow_action" == "true" ]]
then
	echo -e "${GREEN}${BOLD}Followed: $follow_name (@$follow_screen_name) ${RESET}"
	echo "$date_string|$follow_name|@$follow_screen_name|$follow_id" >> "follows/${username}.dat"
else
	echo -e "${RED}${BOLD}Couldn't follow: $follow_name (@$follow_screen_name) ${RESET}"
fi


done

}





# FUNC saved search
##------------------------------------------
##                                 __                             __  
##      _________ __   _____  ____/ /  ________  ____ ___________/ /_ 
##     / ___/ __ `/ | / / _ \/ __  /  / ___/ _ \/ __ `/ ___/ ___/ __ \
##    (__  ) /_/ /| |/ /  __/ /_/ /  (__  )  __/ /_/ / /  / /__/ / / /
##   /____/\__,_/ |___/\___/\__,_/  /____/\___/\__,_/_/   \___/_/ /_/ 
##                                                                    
##------------------------------------------

# TODO add a saved search to list

# TODO choose saved search to search







# FUNC search
##------------------------
##                                 __  
##      ________  ____ ___________/ /_ 
##     / ___/ _ \/ __ `/ ___/ ___/ __ \
##    (__  )  __/ /_/ / /  / /__/ / / /
##   /____/\___/\__,_/_/   \___/_/ /_/ 
##                                     
##------------------------

# TODO local block words
	## dont display tweets from users with certain emojis in username or bio
	## dont display tweets with certain words in the tweet

# TODO dont display tweets from blocked/muted accounts
	## muting	false
	## blocking	true

function search () {
line_count=0
_start=0
_end=100
ProgressBar ${_start} ${_end}

cursor_bottom=$(cat .search_cursor_bottom 2> /dev/null) 
if [ -z "$cursor_bottom" ]
then 
	cursor_bottom_embed=""
else 
	cursor_bottom_embed="&cursor=$cursor_bottom"
fi

tweet_search="lang:en $@ -filter:links -filter:replies"
tweet_search_encoded=$(echo "$tweet_search" | jq -sRr @uri)

## when fixing:
## add $cursor_bottom by itself as a variable after a &
## add &q=$tweet_search_encoded
curl -s "https://twitter.com/i/api/2/search/adaptive.json?include_profile_interstitial_type=1&include_blocking=1&include_blocked_by=1&include_followed_by=1&include_want_retweets=1&include_mute_edge=1&include_can_dm=1&include_can_media_tag=1&include_ext_has_nft_avatar=1&include_ext_is_blue_verified=1&include_ext_verified_type=1&include_ext_profile_image_shape=1&skip_status=1&cards_platform=Web-12&include_cards=1&include_ext_alt_text=true&include_ext_limited_action_results=false&include_quote_count=true&include_reply_count=1&tweet_mode=extended&include_ext_views=true&include_entities=true&include_user_entities=true&include_ext_media_color=true&include_ext_media_availability=true&include_ext_sensitive_media_warning=true&include_ext_trusted_friends_metadata=true&send_error_codes=true&simple_quoted_tweet=true&q=$tweet_search_encoded&tweet_search_mode=live&query_source=typed_query&count=20$cursor_bottom_embed&requestContext=launch&pc=1&spelling_corrections=1&include_ext_edit_control=true&ext=mediaStats,highlightedLabel,hasNftAvatar,voiceInfo,birdwatchPivot,enrichments,superFollowMetadata,unmentionInfo,editControl,vibe" \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
-H 'TE: trailers' --compressed | sed 's/|//g' > out.json

cat out.json | jq . | grep -B1 '"cursorType": "Bottom"' | head -1 | cut -d'"' -f4 > .search_cursor_bottom


## tweets
tweets=$(jq '.globalObjects | .tweets[] | "\(.id_str)|\(.full_text)|\(.user_id_str)|\(.limited_actions)|\(.created_at)|\(.reply_count)|\(.quoted_status_id_str)|\(.card | .card_platform | .platform | .audience | .name)|\(.extended_entities|.media[0]|.type)"' "out.json" | sort -nr)

users=$(jq '.globalObjects | .users[] | "\(.id_str)|\(.name)|\(.screen_name)|\(.can_dm)|\(.friends_count)|\(.normal_followers_count)|\(.location)|\(.description)|\(.profile_background_color)|\(.following)"' "out.json");

rm .search_userlines .search_tweetlines .bad_tweets

touch .bad_tweets

echo -e "${BOLD}$command${RESET} $query ${BOLD}page:${RESET} $search_page" > OUTCOME.txt
echo "" >> OUTCOME.txt

while IFS= read -r line; do

	_start=$(($_start + 5))
	if [[ "$_start" -gt 100 ]]
	then
		_start="100"
	fi
	ProgressBar ${_start} ${_end}

	if [ `expr $line_count % 2` == 0 ]
	then
		rand_color=$(select_color "${colorsA[@]}")
	else
		rand_color=$(select_color "${colorsB[@]}")
	fi

	color=$(colprint "[$rand_color]") 
	user=$(echo "$users" | grep $(echo "$line" | cut -d'|' -f3) | sed 's/"//g')
	tweet=$(echo "$tweets" | grep $(echo "$line" | cut -d'|' -f1))
	tweet_id=$(echo "$tweet" | cut -d'|' -f1 | sed 's/"//g')
	quoted_status_id_str=$(echo "$tweet" | cut -d'|' -f7 | cut -d '"' -f1)
	audience_production=$(echo "$tweet" | cut -d '|' -f8 | cut -d '"' -f1)
	media_type=$(echo "$tweet" | cut -d '|' -f9 | cut -d '"' -f1)
	
	if grep "$tweet_id" .bad_tweets > /dev/null # exclude tweets that were replied to in quotes
	then
		#echo "skipping bad tweet $tweet_id"
		continue
	fi

	if [[ "$quoted_status_id_str" != *"null"* ]] # exclude tweets that are reply quotes
	then
		#echo "$quoted_status_id_str" >> .bad_tweets
		continue
	fi

	if [[ "$audience_production" != *"null"* ]] # skip ads containing 'promotion'
	then
		continue
	fi

	if [[ "$media_type" != *"null"* ]] # skip tweets containing anything but 'null' in media type, ie:photo
	then
		continue
	fi


	line_count=$[$line_count +1]

	#user_displayName=$(echo "$user" | cut -d'|' -f2 | tr -cd '[:alnum:] ._-' | sed 's/ *$//')
	user_name=$(echo "$user" | cut -d'|' -f3)
	tweet_date=$(echo "$tweet" | cut -d'|' -f5 | cut -d '"' -f1)
	converted_date=$(TZ=PST8PDT date -d "$tweet_date" +'%m/%d %I:%M %P')
	users_canDM_Data=$(echo "$user" | cut -d'|' -f4)
	tweet_replies_Data=$(echo "$tweet" | cut -d'|' -f6 | cut -d '"' -f1)

	tweet_replies="" && users_canDM="" && network_karma="" && count_space=""

	if [[ "$tweet_replies_Data" -eq 1 ]]
	then
		tweet_replies="$tweet_replies_Data reply"
	fi

	if [[ "$tweet_replies_Data" -gt 1 ]]
	then
		tweet_replies="$tweet_replies_Data replies"
	fi

	if [[ "$users_canDM_Data" == *"true"* ]]
	then
		if [ -z "$tweet_replies" ]
		then
			users_canDM="Open DM "
		else
			users_canDM="Open DM, "
		fi
	fi

	following_state=$(echo "$user" | cut -d '|' -f10)
	if [[ "$following_state" == *"false"* ]]
	then
		## not following, get the data
		relationship=""
		user_following=$(echo "$user" | cut -d'|' -f5)
		user_followers=$(echo "$user" | cut -d'|' -f6)
		network_karma=$(($user_followers - $user_following))
		karma_format=$(printf "%'d" $network_karma)
		if [[ "$network_karma" == *"-"* ]]
		then
			karma_format=$(echo "$network_karma" | sed 's/-/+/g')
		else
			karma_format=$(echo "$network_karma" | sed 's/^/-/')
		fi
	else
		relationship="FOLLOWING"
		karma_format=""
	fi
	
	## add tweet user lines to file
	echo -e "@$user_name | $converted_date | $relationship$karma_format |$users_canDM$tweet_replies ${RESET}" >> .search_userlines
	## convert userlines into columns
	cat .search_userlines | column -t -s '|' > .search_usercolumns

	## add tweet lines to file
	echo "$(echo "$line" | cut -d'|' -f2)" | sed 's/\\n/ /g' |\
	sed 's/\\r/ /g' | sed 's/\\"/"/g' | sed 's/ \{1,\}/ /g' |\
	tr -cd '[:alnum:][:space:]#?@/:._-' | sed "s/^/$color[$line_count] /" >> .search_tweetlines

done <<< "$tweets"


## combine both files line by line
sed 'R .search_usercolumns' .search_tweetlines >> OUTCOME.txt

clear
## tput rmam ## disable line wrapping for long lines in small terminal

cat OUTCOME.txt
## tput smam ## re-enable line wrapping
echo " "
}




# FUNC store adverts
##---------------------------------------------
##            __                               __                __      
##      _____/ /_____  ________     ____ _____/ /   _____  _____/ /______
##     / ___/ __/ __ \/ ___/ _ \   / __ `/ __  / | / / _ \/ ___/ __/ ___/
##    (__  ) /_/ /_/ / /  /  __/  / /_/ / /_/ /| |/ /  __/ /  / /_(__  ) 
##   /____/\__/\____/_/   \___/   \__,_/\__,_/ |___/\___/_/   \__/____/  
##                                                                       
##---------------------------------------------
## called from inside homepage script
## comment out the line in the homepage function to disable
## loops through homepage results, finds promoted tweets and turns their data into a textfile for the current account
# TODO: fix blank files being made
function store_adverts () {

## gets all promoted tweets from homepage json, removes lines not containing data with sed
jq '{tweet: .data.home.home_timeline_urt.instructions[].entries[]} | .[] | {id: .entryId, date: .content.itemContent.tweet_results.result.core.user_results.result.legacy.created_at, profile_description: .content.itemContent.tweet_results.result.core.user_results.result.legacy.description, profile_url: .content.itemContent.tweet_results.result.core.user_results.result.legacy.entities.url.urls[0].expanded_url, followers: .content.itemContent.tweet_results.result.core.user_results.result.legacy.followers_count|tostring, following: .content.itemContent.tweet_results.result.core.user_results.result.legacy.friends_count|tostring, location: .content.itemContent.tweet_results.result.core.user_results.result.legacy.location, name: .content.itemContent.tweet_results.result.core.user_results.result.legacy.name, screen_name: .content.itemContent.tweet_results.result.core.user_results.result.legacy.screen_name, business_type: .content.itemContent.tweet_results.result.core.user_results.result.professional.category[0].name, ad_text: .content.itemContent.tweet_results.result.legacy.full_text}| join("|")' out.json | sed '/^"|/d' | grep "promoted-" > .ads.json

if [ -s .ads.json ]
then 

## make advertisement directory for current user if doesnt exist
mkdir -p "advertisements/$username"

## loop through ad results and create new files if unique campaigns
while read line; do

	ad_file="$(echo "$line" | cut -d'|' -f1 | cut -d'-' -f3) $(echo "$line" | cut -d'|' -f9)"

	if [ ! -f "advertisements/$username/$ad_file" ]; then

## echo ad block to textfile
echo "https://twitter.com/i/status/$(echo "$line" | cut -d'|' -f1 | cut -d'-' -f3)
$(echo "$line" | cut -d '|' -f2)

$(echo "$line" | cut -d '|' -f8) @$(echo "$line" | cut -d '|' -f9)
$(echo "$line" | cut -d '|' -f10)
Followers: $(echo "$line" | cut -d '|' -f5), Following: $(echo "$line" | cut -d '|' -f6), Location: $(echo "$line" | cut -d '|' -f7)

$(echo "$line" | cut -d '|' -f3)

$(echo "$line" | cut -d '|' -f4)

$(echo "$line" | cut -d '|' -f11 | cut -d '"' -f1)" > "advertisements/$username/$ad_file"

	fi

done <.ads.json

fi # if ads file is not empty loop
}










# FUNC tweet
##---------------------
##       __                     __ 
##      / /__      _____  ___  / /_
##     / __/ | /| / / _ \/ _ \/ __/
##    / /_ | |/ |/ /  __/  __/ /_  
##    \__/ |__/|__/\___/\___/\__/  
##                                 
##---------------------

function tweet () {

# TODO tweet function (tweet from command line) 
	## t heres the tweet text with #hashtag
	## t https://image-here
	## t /home/local/user/image.png
	echo WIP


}



# FUNC profile
##---------------------------
##                        _____ __   
##      ____  _________  / __(_) /__ 
##     / __ \/ ___/ __ \/ /_/ / / _ \
##    / /_/ / /  / /_/ / __/ / /  __/
##   / .___/_/   \____/_/ /_/_/\___/ 
##  /_/                              
##---------------------------
# TODO profile function (view user profile data)
	## p 13, prints tweet #13's profile image in terminal, prints their bio in terminal

function profile () {
	echo WIP
}



# FUNC conversation
##------------------------------------------
##                                                  __  _           
##      _________  ____ _   _____  ______________ _/ /_(_)___  ____ 
##     / ___/ __ \/ __ \ | / / _ \/ ___/ ___/ __ `/ __/ / __ \/ __ \
##    / /__/ /_/ / / / / |/ /  __/ /  (__  ) /_/ / /_/ / /_/ / / / /
##    \___/\____/_/ /_/|___/\___/_/  /____/\__,_/\__/_/\____/_/ /_/ 
##                                                                  
##------------------------------------------
# TODO conversation view
	## c 12, opens the conversation chain for tweet #12
function conversation () {
	echo WIP
}







# FUNC open
##------------------
##                            
##      ____  ____  ___  ____ 
##     / __ \/ __ \/ _ \/ __ \
##    / /_/ / /_/ /  __/ / / /
##    \____/ .___/\___/_/ /_/ 
##        /_/                 
##------------------
# TODO open image or media 
	## o 13, views the media from tweet #13
function open () {

	echo WIP

}



# FUNC inbox
# TODO print inbox



# FUNC message
# TODO send message

# FUNC reply
##---------------------
##                       __     
##      ________  ____  / /_  __
##     / ___/ _ \/ __ \/ / / / /
##    / /  /  __/ /_/ / / /_/ / 
##   /_/   \___/ .___/_/\__, /  
##            /_/      /____/   
##---------------------

function reply () {

tweet_id=$(echo "$@" | cut -d'|' -f1)
tweet_text=$(echo "$@" | cut -d'|' -f2)

variables_query='{"variables":{"tweet_text":"'$tweet_text'","reply":{"in_reply_to_tweet_id":"'$tweet_id'","exclude_reply_user_ids":[]},"dark_request":false,"media":{"media_entities":[],"possibly_sensitive":false},"semantic_annotation_ids":[]},"features":{"tweetypie_unmention_optimization_enabled":true,"vibe_api_enabled":true,"responsive_web_edit_tweet_api_enabled":true,"graphql_is_translatable_rweb_tweet_is_translatable_enabled":true,"view_counts_everywhere_api_enabled":true,"longform_notetweets_consumption_enabled":true,"tweet_awards_web_tipping_enabled":false,"interactive_text_enabled":true,"responsive_web_text_conversations_enabled":false,"longform_notetweets_rich_text_read_enabled":true,"longform_notetweets_inline_media_enabled":false,"blue_business_profile_image_shape_enabled":true,"responsive_web_graphql_exclude_directive_enabled":true,"verified_phone_label_enabled":false,"freedom_of_speech_not_reach_fetch_enabled":true,"standardized_nudges_misinfo":true,"tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled":false,"responsive_web_graphql_skip_user_profile_image_extensions_enabled":false,"responsive_web_graphql_timeline_navigation_enabled":true,"responsive_web_enhance_cards_enabled":false},"queryId":"'$tweet_create_query_ID'"}'



reply_response=$(curl -s "https://twitter.com/i/api/graphql/$CreateTweet" \
-X POST \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'Content-Type: application/json' \
-H 'Referer: https://twitter.com/compose/tweet' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Origin: https://twitter.com' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
-H 'TE: trailers' \
--data-raw "$(echo "$variables_query" | sed 's/\n//g')" --compressed | jq -r '.data | .create_tweet | .tweet_results | .result | .legacy | .id_str');

if [ -z "$reply_response" ]
then
	echo -e "${RED}${BOLD}Error with reply${RESET}"
else
	echo -e "${GREEN}${BOLD}https://twitter.com/${username}/status/${reply_response}${RESET}"
fi

}






# FUNC like
##------------------
##       ___ __      
##      / (_) /_____ 
##     / / / //_/ _ \
##    / / / ,< /  __/
##   /_/_/_/|_|\___/ 
##                   
##------------------

function like () {

like_array=( $strings )
for i in "${like_array[@]}"
do

like_result=$(curl -s "https://twitter.com/i/api/graphql/$FavoriteTweet" \
-X POST \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'Content-Type: application/json' \
-H 'Referer: https://twitter.com/home' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Origin: https://twitter.com' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
-H 'TE: trailers' \
--data-raw '{"variables":{"tweet_id":"'$i'"}}')

#echo "$like_result" | jq .

like_response=$(echo "$like_result" | jq . | grep '"favorite_tweet"' | cut -d'"' -f4)

if [ -z "$like_response" ]
then
	echo -e "${RED}${BOLD}Like failed:${RESET} https://twitter.com/i/status/$i"
else
	echo -e "${GREEN}${BOLD}Liked:${RESET} https://twitter.com/i/status/$i"
fi


done
echo ""

}









# FUNC homepage
##------------------------------
##       __                                              
##      / /_  ____  ____ ___  ___  ____  ____ _____ ____ 
##     / __ \/ __ \/ __ `__ \/ _ \/ __ \/ __ `/ __ `/ _ \
##    / / / / /_/ / / / / / /  __/ /_/ / /_/ / /_/ /  __/
##   /_/ /_/\____/_/ /_/ /_/\___/ .___/\__,_/\__, /\___/ 
##                             /_/          /____/       
##------------------------------

function homepage () {

echo -e "${BOLD}${feed_type}${RESET}" > OUTCOME.txt
echo "" >> OUTCOME.txt

_start=0
_end=100
ProgressBar ${_start} ${_end}


variables_query='{"variables":{
"count":20,
"includePromotedContent":true,
"latestControlAvailable":true,
"requestContext":"launch"
},
"features":{
	"blue_business_profile_image_shape_enabled":true,
	"responsive_web_graphql_exclude_directive_enabled":true,
	"verified_phone_label_enabled":false,
	"responsive_web_graphql_timeline_navigation_enabled":true,
	"responsive_web_graphql_skip_user_profile_image_extensions_enabled":false,
	"tweetypie_unmention_optimization_enabled":true,
	"vibe_api_enabled":true,
	"responsive_web_edit_tweet_api_enabled":true,
	"graphql_is_translatable_rweb_tweet_is_translatable_enabled":true,
	"view_counts_everywhere_api_enabled":true,
	"longform_notetweets_consumption_enabled":true,
	"tweet_awards_web_tipping_enabled":false,
	"freedom_of_speech_not_reach_fetch_enabled":false,
	"standardized_nudges_misinfo":true,
	"tweet_with_visibility_results_prefer_gql_limited_actions_policy_enabled":false,
	"interactive_text_enabled":true,
	"responsive_web_text_conversations_enabled":false,
	"longform_notetweets_rich_text_read_enabled":true,
	"responsive_web_enhance_cards_enabled":false
	}
}'

curl -s "https://twitter.com/i/api/graphql/$HomeLatestTimeline" \
-X POST \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'Content-Type: application/json' \
-H 'Referer: https://twitter.com/home' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Origin: https://twitter.com' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
-H 'TE: trailers' \
--data-raw "$(echo "$variables_query" | sed 's/\n//g')" --compressed | sed 's/|//g' > out.json


store_adverts &
## comment this out to disable advertisement storing 
## disabling is not recommended, the files are interesting to review and it supports twitter


tweets=$(jq '{tweet: .data.home.home_timeline_urt.instructions[].entries[]} | {user: .tweet.content.itemContent.tweet_results.result.core.user_results.result.legacy.screen_name, text: .tweet.content.itemContent.tweet_results.result.legacy.full_text, meta: .tweet.entryId, retweeted: .tweet.content.itemContent.tweet_results.result.legacy.retweeted_status_result.result.__typename, quoted: .tweet.content.itemContent.tweet_results.result.quoted_status_result.result.__typename} | join("|")' out.json | grep -v "|Tweet\||promoted-tweet\|home-conversation\|cursor-" | grep -v '^"||'| head -30)

line_count=0
while read -r line; do

_start=$(($_start + 3)) && ProgressBar ${_start} ${_end}

	line_count=$[$line_count +1]
	if [[ "$line_count" -eq 31 ]]
	then
		break
	fi
	if [ `expr $line_count % 2` == 0 ]
	then
		rand_color=$(select_color "${colorsA[@]}")
	else
		rand_color=$(select_color "${colorsB[@]}")
	fi
	
	color=$(colprint "[$rand_color]")
	
	tweet_username=$(echo "$line" | cut -d '|' -f1 | cut -d'"' -f2)
	tweet=$(echo "$line" | cut -d '|' -f2 | sed 's/\\n/ /g'  | tr -cd '[:alnum:][:space:]#?@/:._-' | sed 's/ \{1,\}/ /g')
	echo -e "$color[$line_count] @$tweet_username: $tweet$RESET" >> OUTCOME.txt

done <<< "$tweets"

clear

cat OUTCOME.txt
echo ""

}


# FUNC notifications
##---------------------------------------------
##                   __  _ _____            __  _                 
##      ____  ____  / /_(_) __(_)________ _/ /_(_)___  ____  _____
##     / __ \/ __ \/ __/ / /_/ / ___/ __ `/ __/ / __ \/ __ \/ ___/
##    / / / / /_/ / /_/ / __/ / /__/ /_/ / /_/ / /_/ / / / (__  ) 
##   /_/ /_/\____/\__/_/_/ /_/\___/\__,_/\__/_/\____/_/ /_/____/  
##                                                                
##---------------------------------------------
## download notifications feed
## loop over entries and get jq data per notification type

function notifications () {

line_count=0 && _start=0 && _end=100
ProgressBar ${_start} ${_end}

## get notifications data
curl -s "https://twitter.com/i/api/2/notifications/all.json?include_profile_interstitial_type=1&include_blocking=1&include_blocked_by=1&include_followed_by=1&include_want_retweets=1&include_mute_edge=1&include_can_dm=1&include_can_media_tag=1&include_ext_has_nft_avatar=1&include_ext_is_blue_verified=1&include_ext_verified_type=1&include_ext_profile_image_shape=1&skip_status=1&cards_platform=Web-12&include_cards=1&include_ext_alt_text=true&include_ext_limited_action_results=false&include_quote_count=true&include_reply_count=1&tweet_mode=extended&include_ext_views=true&include_entities=true&include_user_entities=true&include_ext_media_color=true&include_ext_media_availability=true&include_ext_sensitive_media_warning=true&include_ext_trusted_friends_metadata=true&send_error_codes=true&simple_quoted_tweet=true&tweet_search_mode=live&query_source=typed_query&count=20&requestContext=launch&pc=1&spelling_corrections=1&include_ext_edit_control=true&ext=mediaStats,highlightedLabel,hasNftAvatar,voiceInfo,birdwatchPivot,enrichments,superFollowMetadata,unmentionInfo,editControl,vibe" \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
-H 'TE: trailers' --compressed > out.json


## get read cursor from notifications data
read_cursor=$(jq -r '.timeline | .instructions[1] | .addEntries | .entries[0] | .content.operation.cursor.value' out.json)

## send read cursor to API
curl -s 'https://twitter.com/i/api/2/notifications/all/last_seen_cursor.json' \
-X POST \
-H "$user_agent" \
-H 'Accept: */*' \
-H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'Referer: https://twitter.com/notifications' \
-H 'x-twitter-auth-type: OAuth2Session' \
-H "$token_query" \
-H 'x-twitter-client-language: en' \
-H 'x-twitter-active-user: yes' \
-H 'Origin: https://twitter.com' \
-H 'Sec-Fetch-Dest: empty' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Sec-Fetch-Site: same-origin' \
-H "$authorization_query" \
-H 'Connection: keep-alive' \
-H "$cookie_query" \
--data-raw "cursor=$read_cursor"

result=$(jq -r '.timeline | .instructions[1] | .addEntries | .entries[] | {type: .content.item.clientEventInfo.element|tostring, liked: .content.item.content.notification.id|tostring, tweet_id: .content.item.content.tweet.id|tostring} | join("|")' out.json | grep -v "null|null|null")

rm .notifications_variables

echo -e "${BOLD}${feed_type}${RESET}" > OUTCOME.txt
echo "" >> OUTCOME.txt

while read -r line; do

	_start=$(($_start + 5)) && ProgressBar ${_start} ${_end} 

	if [ `expr $line_count % 2` == 0 ]
	then
		rand_color=$(select_color "${colorsA[@]}")
	else
		rand_color=$(select_color "${colorsB[@]}")
	fi

	color=$(colprint "[$rand_color]") 
	line_count=$[$line_count +1]

	# TODO deal with retweets
	# TODO deal with multiple people liking one status

	type=$(echo "$line" | cut -d '|' -f1)

	echo -n -e "${color}[$line_count] " >> OUTCOME.txt

	if [[ "$type" == *"users_liked_your_tweet"* ]]
	then
		notification_id=$(echo "$line" | cut -d '|' -f2)
		liked_info=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .notifications | .[$notification_id] | {text: .message.text, id: .template.aggregateUserActionsV1.targetObjects[].tweet.id} | join("|")' out.json)
		liked_text=$(echo "$liked_info" | cut -d '|' -f1)
		liked_tweet_id=$(echo "$liked_info" | cut -d '|' -f2)
		liked_tweet=$(jq --arg tweet_id "$liked_tweet_id" '.globalObjects | .tweets | .[$tweet_id].full_text' out.json)
		liked_by_id=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .notifications | .[$notification_id].message.entities[0].ref.user.id' out.json)
		liked_by_user=$(jq -r --arg liked_by_id "$liked_by_id" '.globalObjects | .users | .[$liked_by_id].screen_name' out.json)
		liked_by_name=$(jq -r --arg liked_by_id "$liked_by_id" '.globalObjects | .users | .[$liked_by_id].name' out.json)
		echo "$liked_by_name (@$liked_by_user) liked:" >> OUTCOME.txt
		echo "> $liked_tweet" | sed 's/\\n/ /g' | sed 's/"//g' >> OUTCOME.txt
		echo "$liked_by_id||$liked_by_user" >> .notifications_variables
	fi

	if [[ "$type" == *"user_replied_to_your_tweet"* ]]
	then
		reply_tweet=$(echo "$line" | cut -d'|' -f3)
		reply_text=$(jq --arg reply_tweet "$reply_tweet" '.globalObjects | .tweets | .[$reply_tweet].full_text' out.json)
		reply_from_id=$(jq -r --arg reply_tweet "$reply_tweet" '.globalObjects | .tweets | .[$reply_tweet].user_id_str' out.json)
		reply_from=$(jq -r --arg reply_from_id "$reply_from_id" '.globalObjects | .users | .[$reply_from_id].screen_name' out.json)
		replying_to_id=$(jq -r --arg reply_tweet "$reply_tweet" '.globalObjects | .tweets | .[$reply_tweet].in_reply_to_status_id_str' out.json)
		replying_to_text=$(jq --arg replying_to_id "$replying_to_id" '.globalObjects | .tweets | .[$replying_to_id].full_text' out.json)
		reply_name=$(jq -r --arg reply_from_id "$reply_from_id" '.globalObjects | .users | .[$reply_from_id].name' out.json)
		echo "$reply_name (@$reply_from) replied:" >> OUTCOME.txt
		echo "$reply_text" | sed 's/\\n/ /g' | sed 's/"//g' >> OUTCOME.txt
		echo "> $replying_to_text" | sed 's/\\n/ /g' | sed 's/"//g' >> OUTCOME.txt
		echo "$reply_from_id|$reply_tweet|$reply_from" >> .notifications_variables
	fi

	if [[ "$type" == *"user_liked_multiple_tweets"* ]]
	then
		notification_id=$(echo "$line" | cut -d'|' -f2)
		liked_text=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .notifications | .[$notification_id].message.text' out.json | cut -d' ' -f3)
		liked_by_id=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .notifications | .[$notification_id].message.entities[0].ref.user.id' out.json)
		liked_by_username=$(jq -r --arg liked_by_id "$liked_by_id" '.globalObjects | .users | .[$liked_by_id].screen_name' out.json)
		liked_name=$(jq -r --arg liked_by_id "$liked_by_id" '.globalObjects | .users | .[$liked_by_id].name' out.json)
		echo "$liked_name (@$liked_by_username) liked $liked_text of your tweets" >> OUTCOME.txt
		echo "$liked_by_id||$liked_by_username" >> .notifications_variables
	fi

	if [[ "$type" == *"users_followed_you"* ]]
	then
		notification_id=$(echo "$line" | cut -d'|' -f2)
		followed_text=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .notifications | .[$notification_id].message.text' out.json)
		followed_by_id=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .notifications | .[$notification_id].message.entities[0].ref.user.id' out.json)
		followed_by_username=$(jq -r --arg followed_by_id "$followed_by_id" '.globalObjects | .users | .[$followed_by_id].screen_name' out.json)
		followed_by_name=$(jq -r --arg followed_by_id "$followed_by_id" '.globalObjects | .users | .[$followed_by_id].name' out.json)
		echo "$followed_by_name (@$followed_by_username) followed you" >> OUTCOME.txt
		echo "$followed_by_id||$followed_by_username" >> .notifications_variables 
	fi

	if [[ "$type" == *"user_mentioned_you"* ]]
	then	
		notification_id=$(echo "$line" | cut -d'|' -f3)
		mention_text=$(jq --arg notification_id "$notification_id" '.globalObjects | .tweets | .[$notification_id].full_text' out.json)
		mention_id=$(jq -r --arg notification_id "$notification_id" '.globalObjects | .tweets | .[$notification_id].id_str' out.json)
		reply_from_id=$(jq -r --arg mention_id "$mention_id" '.globalObjects | .tweets | .[$mention_id].user_id_str' out.json)
		from_username=$(jq -r --arg reply_from_id "$reply_from_id" '.globalObjects | .users | .[$reply_from_id].screen_name' out.json)
		from_user=$(jq -r --arg reply_from_id "$reply_from_id" '.globalObjects | .users | .[$reply_from_id].name' out.json)
		echo "$from_user (@$from_username) mentioned you:" >> OUTCOME.txt
		echo "$mention_text" | sed 's/\\n/ /g' | sed 's/"//g' >> OUTCOME.txt
		echo "$reply_from_id|$notification_id|$from_username" >> .notifications_variables
	fi

	if [[ "$type" == *"generic_login_notification"* ]]
	then	
		notification_id=$(echo "$line" | cut -d'|' -f3) 
		echo "generic_login_notification" >> OUTCOME.txt
		echo "||" >> .notifications_variables
	fi
	
	if [[ "$type" == *"users_retweeted_reply_to_you"* ]]
	then	
		notification_id=$(echo "$line" | cut -d'|' -f3) 
		echo "users_retweeted_reply_to_you" >> OUTCOME.txt
		echo "||" >> .notifications_variables
	fi
	
	echo -n -e "${RESET}" >> OUTCOME.txt

done <<< "$result"

}








# FUNC main
##------------------
##                       _     
##      ____ ___  ____ _(_)___ 
##     / __ `__ \/ __ `/ / __ \
##    / / / / / / /_/ / / / / /
##   /_/ /_/ /_/\__,_/_/_/ /_/ 
##                             
##------------------
search_page=1

while :
do

	[[ -z "$command_input" ]] && tips # run tips on first launch
	notifications_alert
	dm=$(echo "$notifications_response" | cut -d '|' -f2)
	notification=$(echo "$notifications_response" | cut -d '|' -f1)
	echo -n "$(tput sgr0)"
	echo "💬 $dm 🔔 $notification"
	read -p -r -ep "$(echo -e $BOLD)@$username > $(echo -e $RESET)" command_input

	# MAIN notifications
	if [[ "$command_input" = "sw" ]]
	then
		SwitchAccount
	fi

	# MAIN like
	if [[ "$command_input" = "l "* ]]
	then
		clear
		cat OUTCOME.txt
		echo ""
		strings="" # reset liked strings
		fix_command=$(echo "$command_input" | sed 's/l //' | sed 's/,/ /g')
		like_array=( $fix_command )
		for i in "${like_array[@]}"
		do
			if [[ "$feed_type" == *"search"* ]]
			then
				like_string=$(sed -n ${i}p <<< "$tweets" | cut -d'|' -f1 | cut -d'"' -f2)
				[[ -z "$like_string" ]] && echo -e "${RED}${BOLD}Can't like this notifcation:${RESET} [$i]"
			fi
			if [[ "$feed_type" == *"homepage"* ]]
			then
				like_string=$(sed -n ${i}p <<< "$tweets" | cut -d'|' -f3 | cut -d'-' -f2)
				[[ -z "$like_string" ]] && echo -e "${RED}${BOLD}Can't like this notifcation:${RESET} [$i]"
			fi
			if [[ "$feed_type" == *"notifications"* ]]
			then
				like_string=$(sed -n ${i}p <<< "$(cat .notifications_variables)" | cut -d'|' -f2)
				[[ -z "$like_string" ]] && echo -e "${RED}${BOLD}Can't like this notifcation:${RESET} [$i]"
			fi
			strings="$strings $like_string"
		done
		like "$strings"
		continue
	fi 

	# MAIN notifications
	if [[ "$command_input" = "n" ]]
	then
		feed_type="notifications" && command="notifications:" && clear
		notifications && clear && cat OUTCOME.txt && echo "" && continue
	fi

	# MAIN follow
	if [[ "$command_input" = "f "* ]]
	then
		clear
		cat OUTCOME.txt
		echo ""
		strings="" # reset followed strings
		fix_command=$(echo "$command_input" | sed 's/f //' | sed 's/,/ /g')
		follow_array=( $fix_command )
		for i in "${follow_array[@]}"
		do
			if [[ "$feed_type" == *"search"* ]]
			then
				follow_string=$(sed -n ${i}p <<< "$tweets" | cut -d'|' -f3)
				[[ -z "$follow_string" ]] && echo -e "${RED}${BOLD}Can't follow this:${RESET} [$i]" && continue
				echo "following: $follow_string"
				strings="$strings $follow_string"
			fi
			if [[ "$feed_type" == *"homepage"* ]]
			then
				echo -e "${RED}${BOLD}You're already following homepage users.${RESET}" && break
			fi
			if [[ "$feed_type" == *"notifications"* ]]
			then
				follow_string=$(sed -n ${i}p <<< "$(cat .notifications_variables)" | cut -d'|' -f1)
				[[ -z "$follow_string" ]] && echo -e "${RED}${BOLD}Can't follow this:${RESET} [$i]" && continue
				echo "following: $follow_string"
				strings="$strings $follow_string"
			fi
		done
		follow "$strings"
		echo ""
		continue
	fi 

	# MAIN reply
	# TODO DM > reply
	if [[ "$command_input" = [0-9]* ]]
	then
		clear
		cat OUTCOME.txt
		echo ""
		tweet_number=$(echo "$command_input" | cut -d' ' -f1)
		fix_command=$(echo "$command_input" | sed "s/$tweet_number //") # removes tweet number from beginning of string
		if [[ "$feed_type" == *"search"* ]]
		then
			tweet_string=$(sed -n ${tweet_number}p <<< "$tweets" | cut -d'|' -f1 | cut -d'"' -f2)
			[[ -z "$tweet_string" ]] && echo -e "${RED}${BOLD}Can't reply to:${RESET} [$tweet_number]\n" && continue
		fi
		if [[ "$feed_type" == *"homepage"* ]]
		then
			tweet_string=$(sed -n ${tweet_number}p <<< "$tweets" | cut -d'|' -f3 | cut -d'-' -f2)
			[[ -z "$tweet_string" ]] && echo -e "${RED}${BOLD}Can't reply to:${RESET} [$tweet_number]\n" && continue
		fi
		if [[ "$feed_type" == *"notifications"* ]]
		then
			tweet_string=$(sed -n ${tweet_number}p <<< "$(cat .notifications_variables)" | cut -d'|' -f2)
			[[ -z "$tweet_string" ]] && echo -e "${RED}${BOLD}Can't reply to notifcation:${RESET} [$tweet_number]\n" && continue
		fi
		reply "$tweet_string|$fix_command"
		continue
	fi

	# MAIN refresh
	if [[ "$command_input" = "r"* ]]
	then
		clear
		if [[ "$feed_type" == *"search"* ]]
		then
			search_page=1 && rm .search_cursor_bottom && query=$(cat .last_search_query) && search "$query"
		fi
		if [[ "$feed_type" == *"homepage"* ]]
		then
			homepage && clear && cat OUTCOME.txt &&echo ""
		fi
		if [[ "$feed_type" == *"notifications"* ]]
		then
			notifications && clear && cat OUTCOME.txt && echo ""
		fi
		continue
	fi 

	# MAIN search	
	if [[ "$command_input" = "s "* ]]
	then
		feed_type="search"
		search_page=1 && command="search:" && clear
		rm .search_cursor_bottom 2> /dev/null # remove old cursor so its not included in new search
		query=$(echo "$command_input" | sed 's/s //')
		echo "$query" > .last_search_query
		search "$query"
		continue
	fi

	# MAIN next page
	if [[ "$command_input" = "np"* ]]
	then
		# TODO add functionality for homepage next page
		search_page=$[$search_page +1] && clear && query=$(cat .last_search_query) && search "$query" && continue
	fi

	# MAIN homepage
	if [[ "$command_input" = "h" ]]
	then
		feed_type="homepage" && command="homepage:" && clear && homepage && continue
	fi

	# MAIN tips
	tips

done
