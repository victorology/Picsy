## item per page on frontend
LIMIT = 25

## item per page on admin
ADMIN_LIMIT = 25

## crawl method, offline or online
## offline for test purpose only, data come from doc folder
## online for production env, data come from real website
CRAWL_METHOD = "online"

### if false, it will only save the url, if true, it will grab the image entirely
CRAWL_IMAGES = true

module DealStatus
  AVAILABLE = 1
  SOLD_OUT = 2
  EXPIRED = 3
end

## save item error log to database while grabbing
ENABLE_ITEM_LOG = true

