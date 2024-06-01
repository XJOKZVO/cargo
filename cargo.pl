#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;    # Module for command-line option parsing
use URI;             # Module for parsing and manipulating URIs (URLs)
use LWP::UserAgent;  # Module for making HTTP requests

print <<'ASCII';
   ___    __ _   _ __    __ _    ___  
  / __|  / _` | | '__|  / _` |  / _ \ 
 | (__  | (_| | | |    | (_| | | (_) |
  \___|  \__,_| |_|     \__, |  \___/ 
                        |___/     

ASCII
my $append_mode  = 0;    # Flag to indicate whether to append to existing query parameters
my $ignore_path  = 0;    # Flag to indicate whether to ignore the path when checking for duplicates
my $custom_port;         # Custom port number to be included in the modified URLs
my $custom_scheme;       # Custom scheme (http/https) for the modified URLs
my $check_links  = 0;    # Flag to indicate whether to check if the modified link works or not
my $help         = 0;    # Flag to indicate whether to display usage information

# Parse command-line options
GetOptions(
    "a"            => \$append_mode,   # -a: Append the value instead of replacing it
    "ignore-path" => \$ignore_path,   # --ignore-path: Ignore the path when considering what constitutes a duplicate
    "p=i"          => \$custom_port,   # -p PORT: Specify a custom port number
    "s=s"          => \$custom_scheme, # -s SCHEME: Specify a custom scheme (http/https)
    "check-links" => \$check_links,   # --check-links: Check if the modified link works or not
    "h"            => \$help          # -h: Display help message
);

# Display usage information if help option is provided
if ($help) {
    print "Usage: $0 [-a] [--ignore-path] [-p PORT] [-s SCHEME] [--check-links] [-h]\n";
    print "-a            Append the value instead of replacing it\n";
    print "--ignore-path Ignore the path when considering what constitutes a duplicate\n";
    print "-p PORT       Specify a custom port number\n";
    print "-s SCHEME     Specify a custom scheme (http/https)\n";
    print "--check-links Check if the modified link works or not\n";
    print "-h            Display this help message\n";
    exit;
}

# Hash to keep track of seen URLs to avoid duplicates
my %seen;

# Create a UserAgent object to make HTTP requests
my $ua = LWP::UserAgent->new;

# Read URLs from standard input and process them
while (<STDIN>) {
    chomp;           # Remove trailing newline character
    my $url = $_;    # Store the URL

    # Parse the URL using the URI module
    my $u = URI->new($url);

    # Extract query parameters from the URL
    my %query_params = $u->query_form;

    # Extract path component from the URL
    my $path = $u->path;

    # Sort query parameter keys for consistent comparison
    my @keys = sort keys %query_params;

    my $key;

    # Determine the key used to identify duplicates based on options
    if ($ignore_path) {
        # If ignoring path, use only hostname and query parameters for key
        $key = $u->host . "?" . join("&", @keys);
    } else {
        # Otherwise, include path along with hostname and query parameters for key
        $key = $u->host . $path . "?" . join("&", @keys);
    }

    # Skip if the URL has been seen before
    next if $seen{$key};

    # Mark the URL as seen
    $seen{$key} = 1;

    # Add custom port number if provided
    if (defined $custom_port) {
        $u->port($custom_port);
    }

    # Add custom scheme if provided
    if (defined $custom_scheme) {
        $u->scheme($custom_scheme);
    }

    # Hash to store modified query parameters
    my %new_query_params;

    # Modify query parameters based on the specified mode
    foreach my $param (keys %query_params) {
        if ($append_mode) {
            # If in append mode, append the value to existing query parameter value
            $new_query_params{$param} = $query_params{$param} . $ARGV[0];
        } else {
            # Otherwise, replace existing query parameter value with the provided value
            $new_query_params{$param} = $ARGV[0];
        }
    }

    # Update the query parameters in the URL object
    $u->query_form(%new_query_params);

    # Print the modified URL
    my $modified_url = $u->as_string;
    print $modified_url, "\n";

    # Check if the modified link works or not
    if ($check_links) {
        my $response = $ua->get($modified_url);
        if ($response->is_success) {
            print "Link works!\n";
        } else {
            print "Link does not work. Error: ", $response->status_line, "\n";
        }
    }
}
