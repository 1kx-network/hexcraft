# use: ./deploy.sh hexwood5 <private_key>

echo "deploying headquarter..."
ds apply -n $1 -k $2 -f map/Headquarter/Headquarter.yaml
echo "-----\n"

echo "deploying team bases..."
ds apply -n $1 -k $2 -f map/BlueBase/BlueBase.yaml
ds apply -n $1 -k $2 -f map/RedBase/RedBase.yaml
echo "-----\n"

echo "deploying class system buildings..."
ds apply -n $1 -k $2 -f characterClasses/config/BardsConcertHall.yaml
ds apply -n $1 -k $2 -f characterClasses/config/ClericsTent.yaml
ds apply -n $1 -k $2 -f characterClasses/config/FightersArena.yaml
ds apply -n $1 -k $2 -f characterClasses/config/PaladinsArmoury.yaml
ds apply -n $1 -k $2 -f characterClasses/config/WizardsMaze.yaml

echo "deploying engineering system buildings..."
ds apply -n $1 -k $2 -f engineers/config/Blacksmith.yaml
ds apply -n $1 -k $2 -f engineers/config/Barrier.yaml
ds apply -n $1 -k $2 -f engineers/config/Cannon.yaml