# Export AWS Cognito user's information to csv and json

## Prerequisites

- Configure AWS Credentials for your session
- Make sure you enabled `Use Unicode UTF-8 for worlwide language support` in your system locale settings

## Summary 

Script is for exporting users for specific client id for your application.
It assumes that you have already json file with export user's information from database (example => {"Email" : "someone@example.com", "Client" : "1"})
awscli will be installed automatically if not found.
The users information for import will be saved to **usersInfoClient_$ClientID.csv** and **usersInfoClient_$ClientID.json**(in the same directory where the script was launched).
Then you can create import job in AWS Cognito Pool with generated csv file.

## Script Arguments

- `-Region` [__Required__] - AWS Region
- `-UserPoolID` [__Required__] - The user pool ID for the user pool on which the export should be performed
- `-ClientID` [__Required__] - The client ID for which the users should be exported
- `-cognitoFilePath` [__Required__] - JSON file with all DB users

## Example

- .\ExportUsersInformation.ps1 -Region *region* -UserPoolID *user-pool-id* -ClientID *client-id* -cognitoFilePath *path-to-cognito-json-file*