# rxmsal

I haven't gotten to polishing this yet, so things are going to be rough but you could get the basic idea.

These programs refresh tokens similar to the Microsoft Authentication Library and stores the fresh token and access token in a JSON file. The Go version also allows authorizing the client for first use.

The idea was taken from [`mutt_oauth2.py`](https://raw.githubusercontent.com/muttmua/mutt/master/contrib/mutt_oauth2.py). This repo simply contains my version that I used in a set of programs to help with setting up Microsoft's XOAUTH2 for my school email, with the aerc email client. Some things are hardcoded for now. I'll clean this up with I have time.
