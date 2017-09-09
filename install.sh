#!/bin/bash
npm install
git clone git@github.com:TheoKlein/Tranquilpeak_ver.TK.git themes/tranquilpeak
cd themes/tranquilpeak
npm install
bower install
npm run prod
