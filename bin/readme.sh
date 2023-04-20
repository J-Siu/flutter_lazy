#!bash

# Generate README.md for https://github.com/J-Siu/flutter_lazy

FILE=README.md

function packages {

	echo "### Packages"
	echo "Pub.dev|Version|Description"
	echo "---|---|---"

	for i in $(find . -type d -d 1 | sort); do
		# echo $i
		PUBSPEC=$i/pubspec.yaml
		if [ -f $PUBSPEC ]; then
			# echo $PUBSPEC

			# name
			NAME=$(grep ^name: $PUBSPEC | cut -d' ' -f2-)
			# echo $NAME

			# description
			DESC=$(grep ^description: $PUBSPEC | cut -d' ' -f2-)
			# echo $DESC

			# version
			VER=$(grep ^version: $PUBSPEC | cut -d' ' -f2-)
			# echo $VER

			PUB="https://pub.dev/packages/$NAME"

			echo "[$NAME]($PUB)|$VER|$DESC"
		fi
	done
}

echo "### Flutter Lazy Library" >$FILE
echo "[![Paypal donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate/?business=HZF49NM9D35SJ&no_recurring=0&currency_code=CAD)" >>$FILE
echo >>$FILE
echo "A collection of packages intended to save time, especially from things that are very repetitive across projects." >>$FILE

packages >>$FILE
