# Dendrite Image Analysis
An old project (ca. 2017) which dealt with segmenting the boundaries of aluminum dendrites in aluminum-silicon alloys and then analyzing the fractal dimension. We tried to find some correlation between processing parameters and micrograph feature (i.e. microstructure), but were unable to do so. All the features we tried had weak correlations, or correlations which defied expectation. The closest we came was with an S-curve fit of the fractal dimension at various length scales. There appeared to be a lower, boundary dimension, and an upper, image dimension. Where the S-curve crossed halfway between them was almost correlated with dendrite scale, and thus cooling rate. Examples of the output can be found, and a ppt presentation with a brief exploratory analysis. The full data set and documentation will not be published.

We believe the most probable reason for failure to find any meaningful correlation is that the images were not produced with the intent to analyze them automatically. The original physical samples were destroyed, and reproducing the samples is costly. The project was merely an attempt to breathe new life into old data using new tools. The project might prove successful if new data were produced keeping in mind the requirements of modern tools.

Below is an example segmented boundary (this image did not contain any dendrites):

![Example S-curve fit.](https://raw.githubusercontent.com/wwarriner/dendrite_analysis/master/example/Al5Si%203Kmm%200.03mmms%200mT%20No1%20%201%20mod_OUT.bmp)

Below is an example S-curve fit for the above boundary image. Note there is an upper fractal dimension around 1.83 (compute a/b + d) and a lower fractal dimension around 1.35 (just d). The half-crossing occurs at about 55 micrometers.

![Example S-curve fit.](https://github.com/wwarriner/dendrite_analysis/blob/master/fit_plot/fit_plot.png)

More information is available in the [PowerPoint](https://github.com/wwarriner/dendrite_analysis/blob/master/Overview.pptx).
