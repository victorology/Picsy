module Scraping
  module RSS
    class Daoneday
      include Scraping::Common
      
      TARGET_PATH = [
        "http://072day.com/linkSite/couponlink_daoneday.php",
        "http://09.youshop.co.kr/rss/daoneday.php",
        "http://124.243.127.13/dailystrip/rss/daoneday.xml",
        "http://52gonggam.com/engine/daoneday.php",
        "http://aeticket.co.kr/rss_daoneday.php",
        "http://beaupon.co.kr/mall/etc/rss_daoneday.php",
        "http://beautyking.co/daoneday.php",
        "http://bestiz509.com/xml/daoneday_xml.php",
        "http://bestplace.co.kr/rss_daoneday.php",
        "http://coumong.com/xml/daoneday_xml.php",
        "http://coupang.com/?act=dispCoupangRss3",
        "http://couponbox.kr/xml/daoneday_xml.php",
        "http://couponmania.co.kr/rss.php?flag=d1day",
        "http://couponscope.net/partner/daoneday.php",
        "http://couponsell.co.kr/editXml/feed_daoneday.php",
        "http://couponville.co.kr/daoneday_rss.php",
        "http://coupop.kr/daoneday.php",
        "http://crazyticket.co.kr/rss.php?CID=daoneday",
        "http://d-deals.com/mall/etc/rss_daoneday1.php",
        "http://daejeon.couponmemory.com/cms/include/daonedayXML.php",
        "http://dailyplus.co.kr/rss_daoneday.php",
        "http://dalincoupon.com/rss/daoneday2.php",
        "http://dccourse.com/rss6.php",
        "http://deallite.co.kr/daoneday.php",
        "http://downfactory.co.kr/daoneday.php",
        "http://downpon.com/rss_daoneday.php",
        "http://eggstrike.co.kr/coupon_daoneday.php",
        "http://fixprice.co.kr/partner/daoneday.php",
        "http://foryourzone.com/super/product/product_daone.php",
        "http://funfunprice.com/partner/daoneday.php",
        "http://g-old.co.kr/rss/daoneday.php",
        "http://gmcestore.com/rss2.php",
        "http://gticket.kr/rss_daoneday2.php",
        "http://halfenjoy.com/rss_daoneday.php",
        "http://halfmake.com/rss_daoneday.php",
        "http://halfpricemotel.co.kr/rss_daoneday.php",
        "http://halfstory.co.kr/xml/xmlHalfstory_new.php?act=daoneday",
        "http://halfu.co.kr/partner/daoneday.php",
        "http://hanamoa.co.kr/linkSite/couponlink_daoneday.php",
        "http://happyansan.com/editXml/feed_daoneday.php",
        "http://happygood.co.kr/xml/daoneday_xml.php",
        "http://happypopee.com/editXml/feed_daoneday.php",
        "http://happyrush.co.kr/xml/_xml_product.php?c=daoneday.com",
        "http://honeybam.com/rss_daoneday.php",
        "http://hottam.co.kr/rss_daoneday.php",
        "http://hulta.net/rss2_daoneday.php",
        "http://icou.co.kr/rssfeed/daoneday(cost).php",
        "http://iubticket.com/partner/daoneday.php",
        "http://jubu9dan.co.kr/rss/ad_daoneday_xml.xml",
        "http://kidspon.com/proc/kidspon_xml_dawon.php",
        "http://kingwangzzang.co.kr/rss_daone.php",
        "http://kkongchi.co.kr/partner/daoneday.php",
        "http://koopon.co.kr/rss/daoneday.xml",
        "http://kupon.co.kr/rss/daonedayXML.kupon",
        "http://livingsocial.co.kr/daoneday.php",
        "http://maimaicoupon.com/daoneday.php",
        "http://massoff.com/partner/daoneday.php",
        "http://misterticket.co.kr/rss_daoneday.php",
        "http://mizday.net/feed/daoneday.php",
        "http://moban.co.kr/rss_daone.php",
        "http://moongssa.com/mall/etc/rss_daoneday2.php",
        "http://mpang.mbn.co.kr/rss_daoneday.php",
        "http://myponpon.com/open_api/daoneday.xml",
        "http://namjaticket.co.kr/xml/index.php",
        "http://nyam.co.kr/kMain/nyam_daoneday.php",
        "http://obaram.co/rss_daoneday.php",
        "http://ondayon.com/partner/daoneday.php",
        "http://onestore.co.kr/partner/daoneday.php",
        "http://onlinesalon.co.kr/shop/admin/goods/onlinesalon_daoneday.xml",
        "http://popcoupon.co.kr/pop/rss_daoneday.asp",
        "http://powerticket.co.kr/rss_daoneday.php",
        "http://qiwi.co.kr/service/daoneday",
        "http://rainbowchoice.com/rss/daoneday.php",
        "http://redticket.co.kr/xml_center/oneday_xml_daoneday.php",
        "http://sale1.co.kr/partner/daoneday.php",
        "http://sevendaily.co.kr/rss_daoneday.php",
        "http://shockingday.co.kr/rss/rss_daoneday.php",
        "http://socialandthecity.co.kr/da_rss.php",
        "http://socialpark.co.kr/rss_daoneday.php",
        "http://starshops.co.kr/partner/daoneday.php",
        "http://styleticket.cafe24.com/rss/daoneday.php",
        "http://sugardeal.co.kr/cooperation.php?c=daoneday",
        "http://surpriseday.co.kr/xml/daoneday_rss.php",
        "http://sweetdeal.co.kr/rss_daoneday.php",
        "http://t-magic.co.kr/xml/daoneday.php",
        "http://tenoclock.co.kr/mall/etc/rss_daoneday.php",
        "http://tgong.co.kr/daonedayRSS.php",
        "http://thecoupon.co.kr/rss_daoneday.php",
        "http://thethumb.co.kr/xml/daoneday_xml.php",
        "http://tibox.co.kr/rss.daoneday.com.php",
        "http://tici.co.kr/xml/new_daoneday_xml.php",
        "http://ticket.yanolja.com/RSS/source/rss.php?p=daoneday",
        "http://ticketdiary.co.kr/daoneday.php",
        "http://ticketgorilla.co.kr/rss.new.daoneday.php",
        "http://ticketkook.com/xml/daoneday_xml.php",
        "http://ticketkorea.kr/rss_daoneday.php",
        "http://ticketmajor.co.kr/Daoneday.xml",
        "http://ticketmonster.co.kr/rss/daOneday.php",
        "http://ticketnight.co.kr/rss/RssDaoneday.php",
        "http://ticketsuda.com/xml/_xml_product.php",
        "http://tickettalk.co.kr/rss_daoneday.php",
        "http://tickple.com/daoneday.php",
        "http://ticuma.com/meta/daone.php",
        "http://tifo.co.kr/rss2.php",
        "http://tikpon.com/rss_daoneday.php",
        "http://tipon.co.kr/rss_daoneday.php",
        "http://tizard.co.kr/mall/etc/rss_daoneday.php",
        "http://togetherangel.co.kr/coupon_daoneday.xml",
        "http://tourboy.co.kr/meta/dawonday_xml.php",
        "http://toursns.com/linkSite/couponlink_daoneday.php",
        "http://ui50.com/rss/daoneday.php",
        "http://vipon.co.kr/xml/daOneday.php",
        "http://weddinggroupon.co.kr/daoneday.php",
        "http://wehalf.com/partner/daoneday.php",
        "http://weniz.co.kr/xml/daoneday.php",
        "http://winwinday.com/rss_daoneday.php",
        "http://www.5gamplus.co.kr/xml/daoneday_xml.php",
        "http://www.allsee.co.kr/xml/daoneday.as",
        "http://www.bandding.co.kr/rss/rss_daoneday.php",
        "http://www.beepon.co.kr/daoneday.xml",
        "http://www.bonus365.co.kr/site/service/co/vip_cpn/daoneday.jsp",
        "http://www.buyallin.co.kr/promotion/xml/daoneday.xml",
        "http://www.buyrus.co.kr/service/daoneday_xml.asp",
        "http://www.catchprice.co.kr/partner/daoneday.php",
        "http://www.cday.co.kr/rss/daoneday_new",
        "http://www.cheapon.co.kr/admin/cumus/rss_goum_dayoneday.php",
        "http://www.cocofun.co.kr/FileStore/JoinPonGoodsXML/daoneday.xml",
        "http://www.couponmemory.com/cms/include/daonedayXML.php",
        "http://www.coupontree.co.kr/mobile/daoneday_2011.asp",
        "http://www.couponzzim.com/rss/daoneday/",
        "http://www.dailypick.co.kr/external/daoneday.xml.php",
        "http://www.dchoney.co.kr/xml/daoneday.php",
        "http://www.dcpang.com/daone.php",
        "http://www.dicket.co.kr/daoneday.php",
        "http://www.dillyday.co.kr/rss_daoneday.php",
        "http://www.enolja.com/rss/daoneday.aspx",
        "http://www.eventticket.co.kr/rss_daoneday.php",
        "http://www.familyceo.com/WS/DaoneDay.ashx",
        "http://www.funirus.co.kr/funirus_xml/daoneday_xml.php",
        "http://www.getprice.co.kr/rss/daoneday_rss.php",
        "http://www.gongguday.com/rss/daoneday.xml",
        "http://www.halinmania.com/partner/daoneday.php",
        "http://www.haruman50.com/partner/daoneday.php",
        "http://www.hijames.com/meta/outer/daoneday_rss.jsp",
        "http://www.id101.co.kr/rss_daoneday.php",
        "http://www.interpark.com/displaycorner/Halftime.do?_method=Link&mapp=daoneday",
        "http://www.itbook.co.kr/rss_daoneday_new.php",
        "http://www.kdprice.com/rssDaoneday.php",
        "http://www.lucky7day.com/xml/daOneday.php",
        "http://www.luckychance.co.kr/rss/daoneday.asp",
        "http://www.mazino.co.kr/editXml/feed_daoneday.php",
        "http://www.moapanda.com/xml/daOneday.php",
        "http://www.myonecard.co.kr/daoneday.jsp",
        "http://www.nolluwaking.com/xml/daOneday.php",
        "http://www.osmell.kr/daoneday.xml",
        "http://www.outdoorticket.com/xml/daoneday_xml.php",
        "http://www.pangpangcp.com/rss/pang_rss_daone.xml",
        "http://www.paranticket.com/partner/daoneday.php",
        "http://www.partywin.co.kr/upload/goods/daoneday.xml",
        "http://www.pm6.co.kr/extern/daoneday.php",
        "http://www.rainbowdays.co.kr/partner/daoneday.php",
        "http://www.sagosipda.com/partner/daoneday.php",
        "http://www.smarticat.co.kr/xml/daOneday.php",
        "http://www.socialsale.co.kr/partner/daoneday.php",
        "http://www.soopang.com/meta/daoneday.html",
        "http://www.ssadaclothes.com/partner/daoneday.php",
        "http://www.ssgmall.buyrus.co.kr/service/daoneday_xml.asp",
        "http://www.stageholic.com/daoneday_rss.php",
        "http://www.star-dc.co.kr/rss_daoneday.php",
        "http://www.stawill.com/famsale/fam_xml_list_daoneday.php",
        "http://www.stylecoupon.co.kr/rss_daoneday.php",
        "http://www.sugardeal.co.kr/aggregator/daoneday.xml",
        "http://www.sweetory.co.kr/info/daoneday.xml",
        "http://www.t-ddang.co.kr/rss_daoneday.php",
        "http://www.tanning.co.kr/partner/daoneday.php",
        "http://www.thisyo.com/daoneday.php",
        "http://www.ticketdosa.co.kr/partner/daoneday.php",
        "http://www.ticketforyou.co.kr/partner/daoneday.php",
        "http://www.ticketman.co.kr/open/xml_daone.asp",
        "http://www.ticketme.co.kr/rss.daoneday.com.php",
        "http://www.ticketmoongchi.com/rss/daoneday.php",
        "http://www.ticketncity.com/xml/daOneday.php",
        "http://www.tnori.co.kr/rss_tnori_dod.php",
        "http://www.tweetpon.com/extapi/daoneday",
        "http://www.univercity.co.kr/rss/daoneday.php",
        "http://www.wemakeprice.com/wemakeplace/rss/daoneday_rss_v2.xml",
        "http://www.wipon.co.kr/rss/daoneday_xml.php",
        "http://www.wishcoupon.com/meta/daoneday.xml",
        "http://www.wonderpon.com/xml/daoneday_pt_xml.asp",
        "http://www.woodc.co.kr/meta/daoneday.xml",
        "http://x2gether.com/meta/daoneday/rss.xml",
        "http://yesdc.net/partner/daoneday.php"
      ]         
      
      def self.crawl_and_save(custom_paths = [])
        require 'open-uri'
        
        results = []
        product = {}
        
        paths = (custom_paths.size > 0) ? custom_paths : TARGET_PATH
        paths.each do |path|
          daoneday = Daoneday.new
          begin 
            doc = Nokogiri::XML daoneday.grab_content(path)
            doc.xpath("//products//product").each do |product_tag|
              ### merged hardcode hash
              product.merge!(daoneday.hardcode_hash)
              ### end of merged
            
              product[:title] = product_tag.xpath("name")[0].content
              product[:original_price] = product_tag.xpath("price")[0].try(:content)
              product[:deal_price] = product_tag.xpath("saleprice")[0].try(:content)
              product[:finish_date] = product_tag.xpath("limitdate")[0].content
              product[:url] = product_tag.xpath("url")[0].content       
              product[:image_url] = product_tag.xpath("image1")[0].try(:content)
              product[:sales_cnt] = product_tag.xpath("salecnt")[0].try(:content).to_i
              product[:max_sales_cnt] = product_tag.xpath("maxcnt")[0].try(:content).to_i
              
              product[:division] = product_tag.xpath("division")[0].try(:content)
              product[:region] = product_tag.xpath("region")[0].try(:content)
              
              product[:rss_source] = path
              product[:rss_kind] = "Daoneday"

              daoneday.create_item(product,product_tag) 
            end  
          rescue Errno::ETIMEDOUT
            daoneday.item_log "timeout error", path 
          rescue Exception => e   
            daoneday.item_log "#{e.message} error", path     
          end  
        end
        return true
      end
        
    end
  end
end      