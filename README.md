# PublicScripts
I will have to say all scripts are ***vibe coded*** + copy/pasted from example scripts, then modified. ***Explained below - Please Read.***
Intended use case is for use with newly installed OS systems without Git.

Public versions of custom Scripts. These scripts try to ommit personal, private or secrete infomation about myself/devices such as username(s) & ips. This means that some scripts just will not work or, will require you to manually edit & import required infomation.

***I DO NOT KNOW WHAT I AM DOING**
I'm not sure if it counts as ***vibe coding*** as I try ***not*** to just copy/paste but actually understand the code.
I am learning via self study using Youtube for explanations/ideas & Public Git Repositorys for example scripts with the help of AI for explanations of and/or generation of snippets to get me started, error fixes, etc.

I have been coding for exactly 4 months via my Windows 11 pc, as of time of writing. ***14/01/2026***
The most coding I have done before 2025 was like videogame settings, a mod for fallout 4 that I legit copy/pasted then changed values of, & in 2025 a docker-compose.yml + settings file(s) for a modified [local-ai-packaged](https://github.com/coleam00/local-ai-packaged.git) / [self-hosted-ai-starter-kit](https://github.com/n8n-io/self-hosted-ai-starter-kit) I messed with for funzies to see if I could run an AI at home & connect to it on the go via a website I brought from cloudflare. 
(Worked great too aside from the secretes left all over the Repository lmao. I actually made it public by mistake once & 4 people stared it within 24 hours.. So that's cool)

***I cannot stress*** how much I just **don't** know, so you will probably find secrets, santax is probably wrong, half of it probably isn't even working & the other half probably doesn't even make sense, let alone the actual oparation of the script execution is probably the wrong order, hell I bet most of em only work on Windows or Ubuntu Server, not Apple & alllll the things inbetween.
if you do find anything wrong, know a better format, or you just see that I simply have the wrong idea about something ***PLEASE*** send us a message & explain, possibly pointing me in the direction of how to fix and/or help me understand what exactly has been done wrong. 
Because well yeah, ***self study with AI*** isn't exactly the best.

***Why now, & Why vibe code?***
Due to Videogames being shit & Windows 11 forcing AI into legit everything (Even the file explorer man, like common dude give me my RAM back) I no longer play games, I no longer want to run Windows on my devices, I also have a hobbie hole to fill, as well as one old, & one new-ish gaming PCs collecting dust. 
Thus the idea of a ***Homelab*** was born! One headless Server (Ubuntu Server 25) & one Workstation (Windows 11). 'Adding a laptop soon with a Linux distro & once comfy will kill the workstation & turn it into a Proxmox or something to mess around with via the lappy'

And so begins the massive learning curve of moving from Windows to Linux, & learning CLI, shell, bash, py, ps1, etc without any schooling or external interpersonal help from an actual teacher that teaches this kinda shit for a living. So I kinda have to use Youtube to study but you can't ask question and get an explanation from a video, Googling for a coherant explanation can take hours, **plus* i'm dyslexic as fuck so fuck reading books man. Meaning I kinda gotta use a third party AI as an alternative, & ChatGPT/Deepseek/All the other free ones are just smarter then my local non fine-tuned generic model.

I hope this repo has helped you a little though, enjoy your day!

***SIDE NOTE ON LOCAL AI***
Local AI is perfect for running generic commands for analyzing logs, formatting data, network checks or monitoring, auto git stuff, even managing file operations & outputting Human-inthe-loop data all in the background all by itself if given the right documentation & platform. 
I use N8N & Email for this. Yep Email.

Not only does it monitor all network traffic, detect Human-Use related things (Like if I was using VSCode & stepped away), perfom tasks on it own (like blocking ips not whitelisted, Gather Real News & not the Mainstream media slop, save copy then push files for development/backup/verioning), and pretty much anything that you could teach a child todo, all in the background all on it's own with Human-inthe-loop sending important information to my Email not only leting me reply as I please, but also let's me send an Email to manually perform tasks without the need for a Domain. Keeping everything private, how it should be.

Documentation is the biggest killer.
Local models are genrally small & dumb.
Local models with complete documentaion including snippets, & examples are genrally smaller & not as dumb.
Local models with complete documentaion including snippets, & examples with working tools/scripts are genrally smaller & not as dumb but can struggle when using tools.
Local Fine-Tuned models are genrally smaller & smarter for the things it needs to do.
Local Fine-Tuned models are with complete documentaion including snippets, & examples are genrally smaller & A LOT smarter, for the things it needs to do.
Local Fine-Tuned models are with complete documentaion including snippets, & examples with working tools/scripts are genrally smaller, A LOT smarter AND can automate pretty much anything that you can jam into any script & dynamically adjust it's current task allowing for complete automation based on set documentaion.
(eg, AI using a command On Windows in the D: drive but needs to be on C: to exec, a simple cd-home.ps1 or something can be set up behind a function (eg, 'GoHome' to exec cd-home.ps1, cd-home.ps1 then exec 'cd ~')
This means you can set up large scripts to do many things & have the AI take the output only keeping your context window small & short.

A good example of 'Local Fine-Tuned models with complete documentaion including snippets, & examples with working tools/scripts' 
Would be a /help bot for native & custom commands fine-tuned to your own language for translating confusing Official Documentation into more **YOU* explanation.
Perfect for Learning Linux because you can use a snippet and fillout your own example for Linux commands you figure out as you go.
Eg, 
/help 'echo'
would return
'Bro echo is the same a print but diff'
And not
'The echo command in Linux is used to display text or variables directly in the terminal, serving as a fundamental tool for user interaction and script debugging.
 It outputs the provided string, variable, or command result to the standard output, which is typically the terminal screen.'

Or a note taking link grabber/downloader auto pusher bot. 
Eg, You see a facebook reel you don't want to lose but you're on the go. You just share via email & the AI will grab the video/image/text/a whole ass webpage etc, download it, then push to a repo for you grouped, timestammped & in it's own folder with it's own notes etc.
Great for keeping Insta or Facebook Reels while on the go. Perfect for conspiracy theroists 😂😂 
 Just thought i'd put it out there since I mentioned the n8n's starter kit & had a lot of fun with it.
