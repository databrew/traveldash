import os
import re
photos = os.listdir(os.getcwd())
photos = ['Rex Tillerson.png', 'Mike Pence.png', 'Donald Trump.png']
for i in range(0, (len(photos)-1)):
	this_photo = photos[i]#.split('xxxx')
	this_photo = re.sub(r' ', '\ ', this_photo)
	print this_photo
	if '.png' in this_photo:
		conversion_text = 'convert -size 200x200 -transparent -border 1%x1% xc:none -fill ' + this_photo + ' -draw "circle 100,100 100,1" circles/' + this_photo 
		print conversion_text
		os.system(conversion_text)