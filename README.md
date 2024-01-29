## Overview

This is a tool for vulnerability diagnosis of public images and Dockerfiles in "Docker hub" using "Trivy". For reference, the results performed by the author are included.

## Description
The images is divided into 5steps.  
In step0, create a target list.  
In step1, perform trivy scan.  
In step2, extract from step1 for data reduction.  
In step3, the results of step2 for multiple axes.  
In step4, the results of the transition on two days.

The dockerfile is divided into 4steps.  
In step0, download target dockerfiles.  
In step1, perform trivy scan.  
In step2, extract from step1 for data reduction.  
In step3, the results of step2 for multiple axes.  

## Requirement　
### example - Author's environment
```sh
pip install -r requirements.txt
```

## Usage

### example - images 

```sh
#step0
$ python3 controller.py images

#step1
$ python3 controller.py images1

#step2
$ python3 controller.py images2 20231115

#step3
$ python3 controller.py images3 20231115

#step4
$ python3 controller.py images4 20231115 20231122
```

### example - dockerfile 
```sh
#step0
$ python3 controller.py dockerfile

#step1
$ python3 controller.py dockerfile1 20231115

#step2
$ python3 controller.py dockerfile2 20231115

#step3
$ python3 controller.py dockerfile3 20231115
```

## Install
```sh
$ git clone https://github.com/kwdlab/2403-Onishi.Yosei.git
```

## References
- [Docker hub](https://hub.docker.com/)
- [trivy](https://trivy.dev/)

## Author
Yosei Onishi

## License
- [MIT](https://opensource.org/licenses/MIT)