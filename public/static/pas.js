function naturalSorter(as, bs){
    var a, b, a1, b1, i= 0, n, L,
	rx=/(\.\d+)|(\d+(\.\d+)?)|([^\d.]+)|(\.\D+)|(\.$)/g;
    if(as=== bs) return 0;
    a= as.toLowerCase().match(rx);
    b= bs.toLowerCase().match(rx);
    L= a.length;
    while(i<L){
	if(!b[i]) return 1;
	a1= a[i],
	b1= b[i++];
	if(a1!== b1){
	    n= a1-b1;
	    if(!isNaN(n)) return n;
	    return a1>b1? 1:-1;
	}
    }
    return b[i]? -1:0;
}

function sortTable(head, table) {
    var idx = $(head).parent().children().index($(head));
    var rows = $('tbody tr', table).get();
    var orig = rows.slice(0, rows.length);
    rows.sort(function(a, b) {
	var av = $(a).children().eq(idx).text()
	var bv = $(b).children().eq(idx).text();
	var res = naturalSorter(av, bv);
	return res;
    });
    var diffs = 0;
    for (var i=0; i < rows.length; i++) {
	var rt = $(rows[i]).children().eq(idx).text();
	var ot = $(orig[i]).children().eq(idx).text();
	if (rt != ot) diffs++;
    }
    if (diffs === 0) rows.reverse();
    $.each(rows, function(index, row) {
	$(table).children('tbody').append(row);
    });
};


$("th.th-sort").on("click", function(e) {
    e.preventDefault();
    var head = e.target;
    var table = $(head).closest("table")[0];
    sortTable(head, table);
});
