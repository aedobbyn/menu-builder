
library(rvest)


recipe_url <- "http://allrecipes.com/recipe/244950/baked-chicken-schnitzel/?internalSource=streams&referringId=1947&referringContentType=recipe%20hub&clickId=st_trending_b"

#' Parse the HTML and save as an object
#+
recipe_page <- read_html(recipe_url)


recipe <- 
  recipe_page %>%
  html_nodes("#lst_ingredients_1") %>% 
  html_text()

recipe <- recipe %>% 
  str_replace_all("ADVERTISEMENT", "") %>% 
  str_replace_all("\n", "") %>% 
  str_replace_all("\r", "")



  <ul class="checklist dropdownwrapper list-ingredients-1" ng-hide="reloaded" id="lst_ingredients_1">
    <li class="checkList__line">
    <label ng-class="{true: 'checkList__item'}[true]" class="checkList__item">
    <input data-id="6307" name="ingredientCheckbox" data-role="none" type="checkbox" value="N" ng-click="saveIngredient($event,6307)">
    <span class="recipe-ingred_txt added" data-id="6307" data-nameid="6307" itemprop="ingredients">1 tablespoon olive oil, or as desired</span>
    </label>
    <!-- ngRepeat: deal in deals["6307"] --><div data-ng-repeat="deal in deals[&quot;6307&quot;]" class="ng-scope" style="">
    <div class="offer-container" data-ng-class="{&quot;hide-deals&quot;:!deals[&quot;6307&quot;] || !localOffersService.localOffersUserEnabled()}">
    <div class="left">
    <p>
    <span class="offer-name ng-binding" data-ng-bind-html="deal.description">Bertolli Extra Virgin Olive Oil, 25.5 oz</span>
    <br>
    <span ng-show="deal.isBIU" data-ng-bind-html="deal.price" class="ng-binding">See Store for Price</span>
    <span ng-show="!deal.isBIU" class="unit-cost ng-binding ng-hide" data-ng-bind-html="deal.priceWithExpiration">See Store for Price - expires in 3 months</span>
    <br>
    <a data-no-follow-if-external="" ng-href="https://www.amazon.com/gp/product/B000VDULAA/?fpw=fresh/ref=as_li_tl?ie=UTF8&amp;camp=1789&amp;creative=9325&amp;creativeASIN=B000VDULAA&amp;linkCode=as2&amp;tag=allrecipes201-20&amp;linkId=e7c794f73ca5b5b7f9f700d9d208a37e" target="_blank" data-ng-click="fireClickPixels(deal.clickPixels)" data-ng-bind-html="deal.clickThroughText" class="ng-binding" rel="nofollow" href="https://www.amazon.com/gp/product/B000VDULAA/?fpw=fresh/ref=as_li_tl?ie=UTF8&amp;camp=1789&amp;creative=9325&amp;creativeASIN=B000VDULAA&amp;linkCode=as2&amp;tag=allrecipes201-20&amp;linkId=e7c794f73ca5b5b7f9f700d9d208a37e">Buy on AmazonFresh</a>
    <br>
    <span class="advertisement" ng-show="deal.isBIU">ADVERTISEMENT</span>
    </p>
    <div class="tracking-element ng-isolate-scope" load-dom-script="" script="deal.moatUrl"><script src="https://z.moatads.com/meredithgroceryserver355539571021/moatad.js#moatClientLevel1=bfeb1eb4e751f03bceffaa649e977927&amp;moatClientLevel2=BIU_AmznFrsh_B000VDULAA&amp;moatClientLevel3=&amp;moatClientLevel4=&amp;moatClientSlicer1=SITE&amp;moatClientSlicer2=PLACEMENT" type="text/javascript"></script></div>
    <!-- ngRepeat: trackingUrl in deal.trackingPixels track by $index --><img class="tracking-element ng-scope" data-ng-repeat="trackingUrl in deal.trackingPixels track by $index" data-ng-src="http://telemetry.allrecipes.com/api/v1/events/impressions/Monetization.BrandedIngredientUnit.Impression/47436105.gif?eventCategory=Delivery.Sponsored&amp;eventParentId=244950&amp;value=%257B%2522ingredientId%2522%253A6307%252C%2522retailerLocationId%2522%253A81544%252C%2522zipCode%2522%253A%252260647%2522%252C%2522upcValue%2522%253A%2522BIU_AmznFrsh_B000VDULAA%2522%252C%2522productCopy%2522%253A%2522Bertolli%2520Extra%2520Virgin%2520Olive%2520Oil%252C%252025.5%2520oz%2522%252C%2522productPrice%2522%253A%2522See%2520Store%2520for%2520Price%2522%252C%2522expirationDate%2522%253A%25222018-03-31%2522%252C%2522clientId%2522%253A%2522bfeb1eb4e751f03bceffaa649e977927%2522%257D&amp;cacheBuster498108" src="http://telemetry.allrecipes.com/api/v1/events/impressions/Monetization.BrandedIngredientUnit.Impression/47436105.gif?eventCategory=Delivery.Sponsored&amp;eventParentId=244950&amp;value=%257B%2522ingredientId%2522%253A6307%252C%2522retailerLocationId%2522%253A81544%252C%2522zipCode%2522%253A%252260647%2522%252C%2522upcValue%2522%253A%2522BIU_AmznFrsh_B000VDULAA%2522%252C%2522productCopy%2522%253A%2522Bertolli%2520Extra%2520Virgin%2520Olive%2520Oil%252C%252025.5%2520oz%2522%252C%2522productPrice%2522%253A%2522See%2520Store%2520for%2520Price%2522%252C%2522expirationDate%2522%253A%25222018-03-31%2522%252C%2522clientId%2522%253A%2522bfeb1eb4e751f03bceffaa649e977927%2522%257D&amp;cacheBuster498108"><!-- end ngRepeat: trackingUrl in deal.trackingPixels track by $index -->
    <!-- ngRepeat: clickUrl in listClickPixels track by $index -->
    </div>
    <div class="right">
    <img data-ng-src="http://images.groceryserver.com/groceryserver/haxor/log/clientId/bfeb1eb4e751f03bceffaa649e977927/zipCode/60647/recipeId/924418/upcValue/BIU_AmznFrsh_B000VDULAA/entityType/promotion/entityId/47436105/retailerLocationId/81544/usage/getRecipeInformationByExternalId/promotion/200x188/300/BIU_AmznFrsh_B000VDULAA.jpg.d.jpg" class="offer-photo" src="http://images.groceryserver.com/groceryserver/haxor/log/clientId/bfeb1eb4e751f03bceffaa649e977927/zipCode/60647/recipeId/924418/upcValue/BIU_AmznFrsh_B000VDULAA/entityType/promotion/entityId/47436105/retailerLocationId/81544/usage/getRecipeInformationByExternalId/promotion/200x188/300/BIU_AmznFrsh_B000VDULAA.jpg.d.jpg">
    </div>
    </div>
    </div><!-- end ngRepeat: deal in deals["6307"] -->
    </li>
    <li class="checkList__line">
    <label ng-class="{true: 'checkList__item'}[true]" class="checkList__item">
    <input data-id="6494" name="ingredientCheckbox" data-role="none" type="checkbox" value="N" ng-click="saveIngredient($event,6494)">
    <span class="recipe-ingred_txt added" data-id="6494" data-nameid="6494" itemprop="ingredients">6 chicken breasts, cut in half lengthwise (butterflied)</span>
    </label>
    <!-- ngRepeat: deal in deals["6494"] -->
    </li>
    <li class="checkList__line">
    <label ng-class="{true: 'checkList__item'}[true]" class="checkList__item">
    <input data-id="16421" name="ingredientCheckbox" data-role="none" type="checkbox" value="N" ng-click="saveIngredient($event,16421)">
    <span class="recipe-ingred_txt added" data-id="16421" data-nameid="16421" itemprop="ingredients">salt and ground black pepper to taste</span>
    </label>
    <!-- ngRepeat: deal in deals["16421"] -->
    </li>
    <li class="checkList__line">
    <label ng-class="{true: 'checkList__item'}[true]" class="checkList__item">
    <input data-id="1684" name="ingredientCheckbox" data-role="none" type="checkbox" value="N" ng-click="saveIngredient($event,1684)">
    <span class="recipe-ingred_txt added" data-id="1684" data-nameid="1684" itemprop="ingredients">3/4 cup all-purpose flour</span>
    </label>
    <!-- ngRepeat: deal in deals["1684"] -->
    </li>
    </ul>

