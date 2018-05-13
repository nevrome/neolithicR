[![Website](https://img.shields.io/website-up-down-green-red/http/shields.io.svg?label=neolithicRC.de)](http://www.neolithicrc.de)
[![Docker Build Status](https://img.shields.io/docker/build/nevrome/neolithicr.svg)](https://hub.docker.com/r/nevrome/neolithicr/)
[![GitHub contributors](https://img.shields.io/github/contributors/nevrome/neolithicR.svg?maxAge=2592000)](https://github.com/nevrome/neolithicR/graphs/contributors) [![license](https://img.shields.io/badge/license-GPL%202-B50B82.svg)](https://github.com/nevrome/neolithicR/blob/master/LICENSE)

# WebGIS-App and Search Engine **[neolithicRC.de](https://www.forschungsdatenarchiv.escience.uni-tuebingen.de/cSchmid/neolithicRC/)**  

Shiny app to search and filter radiocarbon dates from various source databases. neolithicRC is based on the R package [c14bazAAR](https://github.com/ISAAKiel/c14bazAAR). You'll find more information there about

- the included databases and how to cite (!) them
- the meaning of the variables in the output table
- the methods to compile the data

You can run this app on your own system by forking and cloning this repository, installing all the necessary packages and running the Shiny app (`R -e "shiny::runApp('.')"`). Alternatively you can use the prebuilt docker image (`docker run --name your_neolithicrc -d -p 3838:3838 nevrome/neolithicr`) or build it yourself (`docker build -t neolithicrc .` and  `docker run --name your_neolithicrc -d -p 3838:3838 neolithicrc`). The shiny-server.conf in the docker image is custom-tailored to my needs (location: /cSchmid/neolithicRC and websockets disabled) and you should adjust it if you fork.

### Acknowledgements

Thanks to  

- [Dirk Seidensticker](https://uni-tuebingen.academia.edu/DirkSeidensticker) for significant code contributions.
- [Matthias Lang](http://www.escience.uni-tuebingen.de/mitarbeiter/dr-matthias-lang.html) and [Steve Kaminski](http://www.escience.uni-tuebingen.de/mitarbeiter/dr-steve-kaminski.html) of the [eScience-Center](https://www.uni-tuebingen.de/en/facilities/informations-kommunikations-und-medienzentrum-ikm/escience-center.html) (University of Tübingen) for providing and supporting the virtual server space to host the app.
- [Christoph Rinne](https://www.ufg.uni-kiel.de/en/staff-directory/scientific-collaborators/christoph-rinne), [Raiko Krauß](https://www.uni-tuebingen.de/en/faculties/faculty-of-humanities/fachbereiche/altertums-und-kunstwissenschaften/ur-und-fruehgeschichte-und-archaeologie-des-mittelalters/early-history/staff/nach-funktion/krauss-raiko-pd-dr.html) and [Jörg Linstädter ](https://www.dainst.org/mitarbeiter-detailansicht/-/person-display/1241013) and especially [Bernhard Weninger](http://ufg.phil-fak.uni-koeln.de/10115.html?&L=0) for discussion and valuable input.
- [Martin Hinz](https://github.com/MartinHinz) for discussion and code review.  
- All those researches who share their radiocarbon data in public archives. Open Science for the win!

### Project presentations

- (outdated) [Presentation (11.02.2017) -> neolithicRCpres.](https://github.com/nevrome/neolithicRCpres)

### License

For the code in this project apply the terms and conditions of GNU GENERAL PUBLIC LICENSE Version 2. The datasets are published under different licences. 
