---
title: "ViLA: Leveraging General-Purpose Audio for Training Vibration-Based Stadium Crowd Monitoring Models"
summary: "Learning from general-purpose audio to reduce labeled vibration data needed for stadium crowd monitoring."
order: 100
image: /images/projects/vila/stadium.jpg
image_alt: "Crowds filling Michigan Stadium"
published: false
---

**ACM BuildSys 2025 · Best Paper Award**

Yen Cheng Chang, Jesse Codling, Yiwen Dong, Jiale Zhang, Hae Young Noh, and Pei Zhang.

[Read the paper](https://doi.org/10.1145/3736425.3770100)

## Overview

Floor vibrations offer a less intrusive way to monitor stadium crowds. Collecting
labeled vibration data is difficult, making model training a bottleneck.

## Approach

1. Pretrain on unlabeled, general-purpose audio.
2. Fine-tune with a small labeled vibration dataset.
3. Apply the adapted model to stadium crowd monitoring.

## Reported result

Up to **5.8× error reduction** against a model trained without audio pretraining,
in real-world experiments.

[Source: publication abstract](https://hcimaker.github.io/publications/)

<!-- Optional demo section: enable only after adding a real video URL/file.

## Demo video

Add a descriptive link to the video here, or a supported video player.
Suggested local file location: files/projects/vila/demo.mp4
For YouTube/Vimeo, start with a normal link; embedding needs template/CSP support.

-->

<!-- Optional resources section: enable only after adding actual resources.

## Supplementary materials

Add links to a supplementary PDF, code repository, or dataset here.
Suggested local PDF location: files/projects/vila/supplement.pdf

-->

<!-- This example is excluded while it remains under templates/.
To try it in the actual site, copy it to _projects/vila.md and copy the supplied
_guides/assets/vila.jpg to images/projects/vila/stadium.jpg.
Keep published: false while drafting. The current project layout renders this
as a basic Markdown page, not the richer standalone HTML concept.
-->
