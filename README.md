# PEI Lab @ University of Michigan 

The sole purpose of this repository is to create the [PEI lab website](https://peilab.eecs.umich.edu).


## Editing the lab website

Here is how to edit the lab webpage:

1. clone this repository to your local machine
2. make your desired changes (i.e. adding project, members, or publications)
3. rebuild & view your changes locally:
``` bash
jekyll build
jekyll serve
```
4. push your changes to UM's vhost for them to take affect!'
``` bash
scp -r _site/* <uniquename>@vhosts.eecs.umich.edu:/w/peilab/
```
---
Here are more specific notes on how to edit the site:

###  Run the page locally using Jekyll

To run locally, follow instruction [here](https://jekyllrb.com/) to install Jekyll then run `jekyll serve` to see in `localhost:4000`. Here is a brief install guidelines.

```bash
sudo gem install jekyll
jekyll serve
```

### Add yourself

You can add yourself to the page in `_people` folder just create file name `<firstname>_<lastname>.md` in the folder. We require few line of header before you start writing your own page. See the following for the header

``` markdown
---
name: Julia Gersey
position: graduate
avatar: julia-gersey.png
joined: 2024
---
```

If you don't have information, just leave it blank. The avatar will bring photo from `images/people` folder and display it on people page. 
For lab position, you can choose position from 4 classes including `postdoc`, `gradstudent`, `visiting`, `others` (so called Honorary members). Position will put you into section that you choose.

### Add new publications

All publications from the lab are located in `publications.md`. Please upload new publication on your own!


## Internal

### When to Add/Remove Yourself from the Webpage

**When to ADD yourself:**
- When you officially join the PEI Lab as a graduate student, postdoc, research staff, or visiting scholar
- Ideally within your first week of joining the lab

**When to REMOVE yourself:**
- When you graduate or complete your position in the lab
- When transitioning to alumni status (you don't delete your profile, just change your position to 'alumni')
- If you're a visiting scholar, when your visit period ends

### How to Add Yourself to the People Page

1. **Create your profile file:**
   - Navigate to the `_people` folder
   - Create a new file named `<firstname>_<lastname>.md` (all lowercase, e.g., `john_smith.md`)
   
2. **Add the required header:**
   ```markdown
   ---
   name: Your Full Name
   position: [choose one: gradstudent/postdoc/researchstaff/visiting/alumni]
   avatar: yourphoto.jpg
   joined: 2024
   ---
   ```
   
3. **Add your photo:**
   - Add a headshot photo to the `images/people/` folder
   - Name it to match the avatar field in your header (e.g., `your_photo.jpg`)
   
4. **(optional) Write your bio:**
   - After the header, write a brief bio (2-3 paragraphs)
   - Could be your research interests, background, and current projects
   - You can use markdown formatting for links, bold text, etc.

5. **Submit your changes:**
   - If comfortable with git: commit and push your changes, then copy the `_site/` directory to UM's vhost ( /w/peilab/ )
   - If not: email your files to the lab manager or ask for help


If you need help making changes, unsure about the structure, or need help with anything feel free to reach out to Julia. 
