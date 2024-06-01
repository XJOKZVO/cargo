# cargo
This Perl script is designed to modify URLs by appending or replacing query parameters. It also includes options to specify a custom port number, scheme, and to check if the modified links work or not. 

# Processing URLs
The script reads URLs from standard input and processes them one by one. For each URL:

+ Parsing and Extraction: The script uses the URI module to parse the URL and extract query parameters, path, and hostname.
+ Duplicate Detection: The script checks if the URL has been seen before by comparing the key constructed from the hostname, path, and query parameters. If the URL has been seen, it is skipped.
+ Customization: If a custom port number or scheme is specified, the script updates the URL object accordingly.
+ Query Parameter Modification: The script modifies the query parameters based on the specified mode (append or replace).
+ Printing the Modified URL: The script prints the modified URL.
+ Checking the Modified Link: If the --check-links option is specified, the script checks if the modified link works by making an HTTP GET request using the LWP::UserAgent module. If the request is successful, it prints a success message; otherwise, it prints an error message.

# Installation
```
https://github.com/XJOKZVO/cargo.git
```

# Options:
```
   ___    __ _   _ __    __ _    ___  
  / __|  / _` | | '__|  / _` |  / _ \ 
 | (__  | (_| | | |    | (_| | | (_) |
  \___|  \__,_| |_|     \__, |  \___/ 
                        |___/     

Usage: cargo.pl [-a] [--ignore-path] [-p PORT] [-s SCHEME] [--check-links] [-h]
-a            Append the value instead of replacing it
--ignore-path Ignore the path when considering what constitutes a duplicate
-p PORT       Specify a custom port number
-s SCHEME     Specify a custom scheme (http/https)
--check-links Check if the modified link works or not
-h            Display this help message
```

# Usage:
```
# Read URLs from a file named "urls.txt"
cat urls.txt | perl cargo.pl -a -p 8080 -s http --check-links
```
