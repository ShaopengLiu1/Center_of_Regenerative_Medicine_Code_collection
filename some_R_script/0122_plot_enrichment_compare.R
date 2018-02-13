ggplot(t2, aes(x=t2$rup, y=t2$sub_enrich,col=label))+ geom_point(alpha=0.5)+ labs(title="sub_enrichment~raw_rup", x="raw_rup", y="sub_enrich") -> p1

ggplot(t2, aes(x=t2$enrichment, y=t2$sub_enrich,col=label))+ geom_point(alpha=0.5)+ labs(title="sub_enrichment~previous_enrichment", x="previous_enrichment", y="sub_enrich") -> p2

ggplot(t2, aes(x=t2$bg, y=t2$sub_enrich,col=label))+ geom_point(alpha=0.5)+ labs(title="sub_enrichment~background", x="background", y="sub_enrich") -> p3

ggplot(t2, aes(x=t2$rup, y=t2$enrichment,col=label))+ geom_point(alpha=0.5)+ labs(title="previous_enrichment~raw_rup", x="raw_rup", y="previous_enrich") -> p4

ggplot(t2, aes(x=t2$rup, y=t2$sub_rup,col=label))+ geom_point(alpha=0.5)+ labs(title="sub_rup~raw_rup", x="raw_rup", y="previous_rup") -> p5

ggplot(t2, aes(x=t2$rup, y=t2$bg,col=label))+ geom_point(alpha=0.5)+ labs(title="background~raw_rup", x="raw_rup", y="background") -> p6


