phantom.injectJs("./moment.js")
time = "2012-10-5"
console.log "raw time #{time}"
monday = moment(time).add("days", 4).format("YYYY-MM-DD")
new_time = monday + " 20:00"
console.log new_time
