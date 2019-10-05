
/
#############################################################################################
# Author : Himanshu Gupta
# Description: IEX is a new exchange that is slowly becoming popular. It provides a lot
# of its data for free through its API. Recently, it updated its API from v1 to IEX Cloud.
# The new API is more limited on what kind of data you can access and how much of it you can
# access in a given time period for free. To get access to more data, you have to pay.
# You also have to create an IEX Cloud account and pass an authentication token with each
# request.
# You can create an account here: https://iexcloud.io/cloud-login#/register/
# This code is a q/kdb+ wrapper to make it easy to get data from IEX.
# IEX api URL: https://iexcloud.io/docs/api/#api-reference
#############################################################################################
\

/ YOU MUST USER YOUR OWN TOKEN TO BE ABLE TO GET DATA FROM IEX
token:"<insert_your_token_here>";

/ URLs
prefix: "https://cloud.iexapis.com/stable/";
suffix: "?token=",token;

/ Function for converting epoch time
convert_epoch:{"p"$1970.01.01D+1000000j*x};

/ function for issuing a get request and converting json result to a kdb table
get_data:{[url]
  .j.k .Q.hg[url]
 }

/ Get 5 news articles relating to a company
/ q)company_news[`aapl;5]

company_news:{[sym;cnt]

  sym:string(lower sym);
  cnt:string(cnt);
  main_url:raze prefix,"stock/",sym,"/news/last/",cnt,suffix;
  data:get_data[main_url];
  update convert_epoch[datetime] from data

 }

/ Get general info about a company
/ company_info[`aapl]

company_info:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/company",suffix;
  enlist get_data[main_url]

 }

/ Company's key stats
/ key_stats[`aapl]

key_stats:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/stats",suffix;
  data:enlist get_data[main_url];

  update "D"$nextEarningsDate, "D"$exDividendDate from data

 }

/ Get company dividends
/ range can be 1y, 2y, 5y, ytd, 6m, 3m, 1m, next
/ dividends[`aapl;"1y"]

dividends:{[sym;range]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/dividends/",range,suffix;
  data:get_data[main_url];

  update "D"$exDate, "D"$paymentDate, "D"$recordDate, "D"$declaredDate, "D"$date from data

 }

/ Get company's earnings
/ can only get last quarter's earnings with free plan
/ earnings[`aapl;2]

earnings:{[sym;cnt]

  sym:string(lower sym);
  cnt:string(cnt);
  main_url:raze prefix,"stock/",sym,"/earnings/",suffix,"&last=",cnt;
  data:get_data[main_url][`earnings];

  update "D"$EPSReportDate, "D"$fiscalEndDate from data

 }


/ Get today's earnings
/ before the open: today_earnings[`aapl][`bto]
/ after market close: today_earnings[`aapl][`amc]
/ during trading day: today_earnings[`aapl][`dmt]

today_earnings:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/today-earnings/",suffix;
  get_data[main_url]

 }

/ Historical prices for a given range
/ Available ranges are: 1d, 5d, 5dm (10 min intervals) 1m, 1mm (30 min intervals), 3m, 6m, ytd, 1y, 2y, 5y, max
/ historical_prices_range[`aapl;"1d"]

historical_prices_range:{[sym;range]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/chart/",range,suffix;
  data:get_data[main_url];

  update "D"$date, "U"$minute from data

 }

/ Historical prices for a specific day
/ historical_prices_day[`aapl;"20191004"]

historical_prices_day:{[sym;date]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/chart/","date/",date,suffix;
  data:get_data[main_url];

  update "D"$date, "U"$minute from data

 }


/ Intraday prices for latest trading day
/ intraday_prices[`aapl]

intraday_prices:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/intraday-prices",suffix;
  data:get_data[main_url];

  update "D"$date, "U"$minute from data

 }


/ Data for most active stocks of the day
/ most_active[]

most_active:{

  main_url:raze prefix,"stock/market/list/mostactive",suffix;
  data:get_data[main_url];

  update convert_epoch[openTime], convert_epoch[closeTime],convert_epoch[latestUpdate],convert_epoch[iexLastUpdated],convert_epoch[delayedPriceTime],convert_epoch[extendedPriceTime] from data
 }

/ Top gainers of the day
/ gainers[]

gainers:{

  main_url:raze prefix,"stock/market/list/gainers",suffix;
  data:get_data[main_url];

  update convert_epoch[openTime], convert_epoch[closeTime],convert_epoch[latestUpdate],convert_epoch[iexLastUpdated],convert_epoch[delayedPriceTime],convert_epoch[extendedPriceTime] from data
 }

/ Top losers of the day
/ losers[]

losers:{

  main_url:raze prefix,"stock/market/list/losers",suffix;
  data:get_data[main_url];

  update convert_epoch[openTime], convert_epoch[closeTime],convert_epoch[latestUpdate],convert_epoch[iexLastUpdated],convert_epoch[delayedPriceTime],convert_epoch[extendedPriceTime] from data
 }

/ Company's previous day data - HLOC
/ previous_day[`aapl]

previous_day:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/previous",suffix;
  data: enlist get_data[main_url];

  update "D"$date from data

 }

/ Company's latest quote
/ quote[`aapl]

quote:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"stock/",sym,"/quote",suffix;
  data:enlist get_data[main_url];

  update convert_epoch[openTime], convert_epoch[closeTime],convert_epoch[latestUpdate],convert_epoch[iexLastUpdated],convert_epoch[delayedPriceTime],convert_epoch[extendedPriceTime] from data

 }

/ Quotes for cryptos
/ .crypto.quote[`btcusd]

.crypto.quote:{[sym]

  sym:string(lower sym);
  main_url:raze prefix,"crypto/",sym,"/quote",suffix;
  data:enlist get_data[main_url];

  update convert_epoch[latestUpdate] from data

 }

/ Crypto ref data - available crypto pairs
/ .ref.crypto_syms[]

.ref.crypto_syms:{

  main_url:raze prefix,"ref-data/","crypto/","symbols",suffix;
  data:get_data[main_url];

  update "D"$date from data
 }

/ IEX ref data (more detailed) - more info about available IEX syms
/ .ref.syms[]

.ref.syms:{

  main_url:raze prefix,"ref-data/","symbols",suffix;
  data:get_data[main_url];

  update "D"$date from data
 }

/ Latest quote and trade for one or more companies
/ latest_quote_trade[`aapl`ibm]
/ This function will only on days when markets are open

latest_quote_trade:{[syms]

  syms:$[1<count syms;"," sv string(upper syms);string(syms)];
  main_url: prefix,"tops",suffix,"&symbols=",syms;
  data:get_data[main_url];

  update convert_epoch[lastUpdated],convert_epoch[lastSaleTime] from data

 }
