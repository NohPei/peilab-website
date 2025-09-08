---
title: People
permalink: /people/
---

{% assign people_sorted = site.people | sort: 'joined' %}
{% assign role_array = "pi|postdoc|gradstudent|researchstaff|visiting|others|alumni" | split: "|" %}

{% for role in role_array %}

{% assign people_in_role = people_sorted | where: 'position', role %}

<!-- Skip section if there's nobody -->
{% if people_in_role.size == 0 %}
  {% continue %}
{% endif %}

<div class="pos_header">
{% if role == 'postdoc' %}
<h3>Postdoctoral Fellows</h3>
 {% elsif role == 'pi' %}
<h3>Principal Investigator</h3>
 {% elsif role == 'gradstudent' %}
<h3>PhD Students</h3>
 {% elsif role == 'visiting' %}
<h3>Visiting Students</h3>
 {% elsif role == 'others' %}
<h3>Master & Undergrad Students</h3>
 {% elsif role == 'alumni' %}
<h3>Alumni</h3>
{% endif %}
</div>

{% if role != 'alumni' %}
<div class="content list people">
  {% for profile in people_sorted %}
    {% if profile.position contains role %}
      <div class="list-item-people">
        <p class="list-post-title">
          {% if profile.avatar %}
            <a href="{{ site.baseurl }}{{ profile.url }}"><img class="profile-thumbnail" src="{{site.baseurl}}/images/people/{{profile.avatar}}"></a>
          {% else %}
            <a href="{{ site.baseurl }}{{ profile.url }}"><img class="profile-thumbnail" src="https://via.placeholder.com/200x200?text=No+Photo"></a>
          {% endif %}
          <a class="name" href="{{ site.baseurl }}{{ profile.url }}">{{ profile.name }}</a>
        </p>
      </div>    
    {% endif %}
  {% endfor %}
</div>
<hr>

{% else %}

<br>

| Who are they | When were they here | Where they went |
| :------------- |:-------------| :-----------|
| [Tony Liu](https://tliutony.github.io/) | Graduate Student (2018-2024) | Assistant Professor of Computer Science, Mount Holyoke College |
| [Xinyue Wang](https://www.charonwangg.com/) | Graduate Student (2021-2023) | PhD Student, Halıcıoğlu Data Science Institute, UCSD |
| [Ilenna Jones](https://www.ilenna.com/) | Graduate Student (2017-2023) | Postdoc, Kemptner Institute, Harvard|
| [Ben Baker](https://www.tbenbaker.com/) | Post-doc (2021-2023) | Assistant Professor of Philosophy at Colby|
| [Richard Lange](https://www.rit.edu/directory/rdlvcs-richard-lange)  | Post-doc (2021-2023) | Assistant Professor at Rochester University|
| Justin Brantley | Post-doc (2021-2023) | Data Scientist, Texas Rangers, yes they did win the super something twice in a row after he joined them |
| [Ari Benjamin](https://ari-benjamin.com/) | Graduate student (2016-2022) | Postdoc with Tony Zador at Cold Spring Harbor Laboratory |
| [Titipat Achakulvisut](https://kordinglab.com/people/titipat_achakulvisut/.index.html) | Graduate Student (2014 - 2021) | [Biomedical and Data Lab](https://biodatlab.github.io/), Dept of Biomedical Engineering, Mahidol University, Thailand |
| [Pedro Ribeiro](https://www.linkedin.com/in/pedro-ribeiro/) | Graduate Student (2018 - 2021) | Programmer Analyst at Cedars-Sinai Department of Computational Biomedicine|
[Nidhi Seethapathi](https://www.seethapathilab.org) | Postdoc (2018 - 2021) | Assistant Professor at MIT BCS and EECS |
| [Ben Lansdell](http://benlansdell.github.io) | Postdoc (2017 - 2020) | Data Scientist at St. Jude Children's Research Hospital |
| [David Rolnick](http://kordinglab.com/people/david_rolnick/index.html) | Postdoc (2018 - 2020) | [Assistant Professor](http://www.davidrolnick.com), Computer Science, McGill University and Mila |
| [Shaofei Wang](http://kordinglab.com/people/shaofei_wang/index.html) | Researcher (2018 - 2020) | PhD Student, Computer Science, ETH Zurich |
| [Ethan Blackwood](http://kordinglab.com/people/ethan_blackwood/index.html) | Rotation Student (2019) | Alex Proekt's Lab at UPenn |
| [Steve Antos](http://kordinglab.com/people/steve_antos/index.html) | Graduate Student (2012 - 2019) | Analytics Developer |
| [Sofia Triantafillou](https://www.dbmi.pitt.edu/node/54091) | Postdoc (2016 - 2018) | Assistant Professor of Biomedical Informatics at University of Pittsburgh |
| [Gaiqing Kong](https://gaiqingkong.github.io/) | Visiting Scholar (2016 - 2018) | Fyssen Foundation Postdoc at INSERM, France |
| [Claire Chambers](http://kordinglab.com/people/claire_chambers/index.html)  | Postdoc (2015 - 2018) | Data Scientist in Ireland |
| [Josh Glaser](https://jglaser2.github.io) | Graduate Student (2012 - 2018) | Postdoc at Columbia |
| [Daniel Wood](http://kordinglab.com/people/daniel_wood/index.html) | Postdoc (2014 - 2017) | Data Scientist at SharpestMinds |
| [Bahram Yoosefizonooz](http://kordinglab.com/people/bahram_yoosefizonooz/index.html) | Visiting (2017) | NavInfo Europe |
| Elahe Arani | Visiting (2017) | NavInfo Europe |
| [Luca Lonini](http://kordinglab.com/people/luca_lonini/index.html) | Postdoc (2017) | Research Scientist at Shirley Ryan Ability Lab |
| [Ravi Garg](http://kordinglab.com/people/ravi_garg/index.html) | Undergrad Research | MBA Candidate at Kellogg School |
| [Sohrob Saeb](http://kordinglab.com/people/sohrob_saeb/index.html) | Postdoc (2014 - 2017) | Data Scientist at Verily |
| [Eva Dyer](http://kordinglab.com/people/eva_dyer/index.html) | Postdoc (2017) | Assistant Professor of Biomedical Engineering at Georgia Tech and Emory U |
| [Pavan Ramkumar](http://kordinglab.com/people/pavan_ramkumar/index.html) | Postdoc (2017) | Director of ML at Herophilus |
|

{% endif %}
{% endfor %}
