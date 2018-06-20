from PIL import Image, ImageEnhance
import os
import sys
def test():
  batch("/Volumes/External/highres/", "/Volumes/External/webres3/")

def batch(infolder, outfolder):

  for root, dirs, files in os.walk(infolder):
    for name in files: 
      print(name)
      if ".jpg" in name and '.DS' not in name and '._' not in name:
        if not os.path.isfile(outfolder + name):
          try:
            im = Image.open(os.path.join(root, name))
            profile = im.info.get('icc_profile')
            # resize based on 450px wide
            if im.size[0] > im.size[1]:
              if im.size[0] > 500:
                basewidth = 500
                wpercent = (basewidth/float(im.size[0]))
                hsize = int((float(im.size[1])*float(wpercent)))
                im = im.resize((basewidth,hsize), Image.ANTIALIAS)
            else:
              if im.size[1] > 500:
                baseheight = 500
                hpercent = (baseheight/float(im.size[1]))
                wsize = int((float(im.size[0])*float(hpercent)))
                im = im.resize((wsize,baseheight), Image.ANTIALIAS)
            im.save( os.path.join(outfolder, name), "JPEG",quality=100, dpi=(72,72), icc_profile=profile)
          except:
            print("Unexpected error:", sys.exc_info()[0])
        else:
          print("File exists: "+ name)

if __name__ == '__main__':
    test()
