# use: ./deploy.sh hexwood5 <private_key>

echo "deploying headquarter..."
ds apply -n $1 -k $2 -f map/game/config/Headquarter.yaml
echo "-----\n"

echo "deploying team bases..."
ds apply -n $1 -k $2 -f map/game/config/BlueBase.yaml
ds apply -n $1 -k $2 -f map/game/config/RedBase.yaml
echo "-----\n"

echo "deploying class system buildings..."
ds apply -n $1 -k $2 -f map/characterClasses/config/BardsConcertHall.yaml
ds apply -n $1 -k $2 -f map/characterClasses/config/ClericsTent.yaml
ds apply -n $1 -k $2 -f map/characterClasses/config/FightersArena.yaml
ds apply -n $1 -k $2 -f map/characterClasses/config/PaladinsArmoury.yaml
ds apply -n $1 -k $2 -f map/characterClasses/config/WizardsMaze.yaml

echo "deploying engineering system buildings..."
ds apply -n $1 -k $2 -f map/engineers/config/Blacksmith.yaml
ds apply -n $1 -k $2 -f map/engineers/config/Barrier.yaml
ds apply -n $1 -k $2 -f map/engineers/config/Cannon.yaml