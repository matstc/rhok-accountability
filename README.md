This is an automated expense system where users can submit expenses by SMS.

For more information on the use case, see RHoK's [problem statement](http://www.rhok.org/problems/accountability).

# How to Set Up
- You will need a [heroku](http://heroku.com) account and their [toolbelt](https://devcenter.heroku.com/articles/quickstart) installed.
- You will need a [Twilio account](https://www.twilio.com/).
- You will need a [Gmail account](https://www.gmail.com/) to handle the creation of spreadsheets. Use a new Gmail account for better experience.

### 1 – Clone this repository
Enter this command into your terminal:

  `git clone git@github.com:matstc/rhok-accountability.git`

### 2 – Deploy on heroku
Then enter these commands into your terminal:

  `cd rhok-accountability`

  `heroku create`

  `git push heroku master`

### 3 – Configure the gmail account to manage spreadsheets

  `heroku config:add gmail=GMAIL_ACCOUNT_USERNAME`

  `heroku config:add gmailp=GMAIL_ACCOUNT_PASSWORD`

The application should now be running at heroku's URL.

OPTIONAL: if you want to show an email address for users to contact in case they need help, set the `help_email` variable like this:

  `heroku config:add help_email=YOUR_EMAIL_ADDRESS`

The email address will then be shown on the main page.
 
### 3 – Create your spreadsheet

Go to heroku's URL and fill out the following form:

![](https://raw.github.com/matstc/rhok-accountability/master/public/images/index.png)

Once you click the "create" button, you will see a link to a Google spreadsheet. The person with that email address is now the owner of that spreadsheet.

The phone number should start with + and follow international conventions (and should not contain any spaces).

### 4 – Setting up Twilio
Once you have a Twilio account, make sure you register a number. Then go to your number's settings and add the appropriate SMS request URL. The request URL follows the format `http://HEROKU_URL/application/add`. For instance, if your heroku URL is `myapp.herokuapp.com` then your request URL will be `http://myapp.herokuapp.com/application/add`

![](https://raw.github.com/matstc/rhok-accountability/master/public/images/twilio-setup.png)

### 5 – Try it out
Things should now work. If you text something to the phone number you used to set up your spreadsheet, you should see a new expense row in the spreadsheet.

![](https://raw.github.com/matstc/rhok-accountability/master/public/images/spreadsheet-screenshot.png)

Format your message with commas in-between values. For example:

`pencils, 14.50$, extra stationery`

