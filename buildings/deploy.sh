# use: ./deploy.sh hexwood5 <private_key>

node ./node_modules/@playmint/ds-cli/dist/ds.js  apply -n $1 -k $2 -f config/BardsConcertHall.yaml
echo "-----\n"
node ./node_modules/@playmint/ds-cli/dist/ds.js  apply -n $1 -k $2 -f config/ClericsTent.yaml
echo "-----"
node ./node_modules/@playmint/ds-cli/dist/ds.js  apply -n $1 -k $2 -f config/FightersArena.yaml
echo "-----"
node ./node_modules/@playmint/ds-cli/dist/ds.js  apply -n $1 -k $2 -f config/PaladinsArmoury.yaml
echo "-----"
node ./node_modules/@playmint/ds-cli/dist/ds.js  apply -n $1 -k $2 -f config/WizardsMaze.yaml