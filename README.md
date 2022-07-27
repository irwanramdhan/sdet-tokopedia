# sdet-tokopedia
I'm using Ruby Capybara for the API automation

There are 5 main folder for the API automation

The app folder consist of configs and models
The configs are to store the api endpoint and the credential for the script
Why I separate the credential to one personal folder, because sometimes there is diffrences for different user level, like admin or employee or customer
The models is to connect between yml file and the steps file

The support folder consist of env and hook
Its mostly consist of supporting software that are required for the script to run

The data folder consist yml file
The yml file is for the request body

The feature folder consist feature file
Feature file is for the test cases and written in gherkin

The report folder will consist the result of the most recent automation script that has been run
Whether its resulted in success or error, the system will store the screenshot of the result

The step_definitions folder consist of steps file
Steps file are the the automation script, its writtern ruby progamming using selenium capybara framework
In steps file you may notice that there is the following script 'Time.now.strftime('%T')'
Its to format timestamp into string, but the script only format in hour, minute and seconds in 24 hour format, not in miliseconds as requested
Because I though it will be different and resulted in error if we count in miliseconds when during the system is retrieving the timestamp and during the created request
As for the script the approach will go like this :
    1. System will create new order
    2. System will retrieve the recently created order and make sure that the created order detail is correct

To run you can use the following command 'cucumber feature/tokopedia.feature'
