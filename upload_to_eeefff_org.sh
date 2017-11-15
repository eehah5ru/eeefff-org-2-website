stack exec site -- clean &&
    stack exec site -- build &&
    rsync -avzh  _site/* deploy.do.myfutures.trade:/var/www/eeefff-org
