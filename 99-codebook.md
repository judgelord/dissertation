This codebook describes the coding of public comments on proposed agency rules.

### Coding Comments
A position will eventually be identified for all comments, but the first step is to identify the positions of comments by organizations and elected officials (other comments are generally identified automatically from textual similarity). This scheme (especially the `org_type`, `ask`, and `success` variables) builds on work by Susan Webb Yackee [e.g., @Yackee2006JPART; @Yackee2006JOP].


`DATE` = the date on the comment. If the comment is not dated, this defaults to the date that the agency received the comment. 


Initially, we code position on the main dimension of conflict (it may be a challenging interpretive task to identify the main dimension of conflict raised by a comment). 


`position` =     


- "1" Opposed to the rule change for moving in the wrong direction (e.g., "We need stronger, not weaker regulations" or "These regulations are already bad for our business, we should not make them even more strict") 
- "2" Opposed to the change, prefers no change, though they might be ok with some change
- "3" Supports the rule change, but asking for less (e.g., "we applaud EPA's efforts to regulate ..., but would prefer less severe limits" or "The Guild recognizes the need to have uniform regulations which the proposed rules address. Still, the Guild takes issue with some of the proposed changes") 
- "4" Supports the rule change as is 
- "5" Supports the rule change but asking for more 
- "6" Opposed to the rule change for not going far enough  (e.g. " While the proposed rule may improve current protections to some degree, it is utterly inadequate...If the agency fails to revise the rule to incorporate such measures, then they should withdraw the proposed rule completely"
https://www.regulations.gov/comment/NOAA-NMFS-2020-0031-0668) 
- "0". Only if there is really no position of any kind on the policy


Note that a commenter can support a rule that is moving in a deregulatory direction. This means that they oppose regulation and thus support the rule (because the rule is rolling back regulation). What matters here is their position on the change from the status quo (current policy) to the proposed rule, not on regulation in general. These positions correspond to a commenter's ideal policy (their "ideal point" in the policy space). If a commenter's ideal policy is at position 1 in the figure below, the proposed rule change is moving policy in the opposite direction they want it to move, hence their position is "opposed to the rule change for moving in the wrong direction." Similarly, if the current policy (the status quo) is a commenter's ideal policy, their ideal point is at or near the current policy (x1), position 2, and they are opposed to the proposed rule change.
  

```{r spatial-coding2, fig.cap = "Instructions for Coding the Position of a Comment Given Current Policy, X1, and proposed policy, X2", out.width = "70%"} 
knitr::include_graphics(here::here("figs", "spatial-coding.png"))
```
If the commenter's ideal policy is at positions 3, 4, or 5, these ideal policies are closer to the new policy, X2 than the current policy X1, and thus they are likely to support the rule change. If the commenter's ideal policy is at position 6, the change from X1 to X2 is insufficient for them to support it (even though it is technically moving in the direction they would like). This is rare, but commenters do occasionally reject proposed rules for doing too little. Their hope is that by rejecting this proposed policy (even though it moves policy in their preferred direction), they might get a better policy later.
  
  

________________




`position_certainty` =  


"1" = fairly certain (may also be left blank), "2" = unsure, "3" = totally unclear


________________




`coalition_comment` = Is this commentator lobbying alongside other commenters in a fashion that suggests they are a coordinated coalition? If so, put the name of one of the other main organizations in the coalition here and use this for all comments with compatible asks. Coalitions may be implicit (compatible asks, even if they don't mention the other organizations) or explicit (e.g. "In terms of specific reservations about the proposed changes, we associate ourselves with the letter from ACLU"). There may often be only one coalition commenting on a rule (especially for rules with few comments). It is harder to identify the sides of a debate where only one side shows up, but we must be careful not to artificially break up essentially aligned interests just to have a conflict between commenters. The conflict that matters is generally on the main dimension(s) of conflict at issue in the policy. If everyone is 3s and 4s (or 1s and 2s)  they will more often all be one big coalition pushing generally in the same direction with compatible asks than several smaller ones pushing in different incompatible directions. Position and coalition are not synonymous, but they are highly correlated.


`coalition _type` =    
The key distinction here is typically whether the lead organizations will profit from the coalition's advocacy (even if some of the organizations in the coalition are nonprofits)  


- "public" if this coalition is primarily lobbying on behalf of some idea of the public interest (two organizations lobbying on the same rule may have opposing ideas of the public interest, but oftentimes public interests conflict with private interests)   
- "private" if this coalition is mainly on behalf of private interests (even if not their own or if using language evoking the public interest, as most lobbying does)


`comment_type`  = 
 
- "org" any kind of organization making substantive suggestions  
- "elected" Is this comment from an individual elected official (e.g., U.S. House or Senate). Add a specific type of elected official after a semicolon "elected; house, elected; senate, elected; governor, elected; state senate, county commissioner, etc.  
- "individual" an individual who is writing in their personal capacity, not on behalf of an organization or office (even if they use an organization's letterhead), and is not part of an organized petition-like campaign  
- "corp campaign" a form letter used  by many (often small) businesses (org_name and org_type will still be the organization (e.g. the name of the small business and "corp;small business")  
- "mass" a petition-like campaign  
  -  "mass;grassroots" - individuals who genuinely care   
  -  "mass;astroturf"  campaigns are intended to create a deceptive appearance of public support. The group organizing the campaign is only doing so because they are being paid. The individuals mobilized are often either deceived (e.g., intentionally misled about the policy or its likely effects) or financially incentivized to participate. In the extreme, astroturf campaigns may use the names of fake or non-consenting individuals. In contrast, a more grassroots campaign may also require funding, but groups would choose to use resources for such a campaign even without the quid pro quo, and individuals are mobilized based on some pre-existing interest or belief. While grassroots campaigns may involve simplification, spin, and even mild deception, it is not decisive to the campaign. If you find yourself thinking "why are these people supporting this company/industry?" it might be astroturf.   
  - "mass;corp campaign" - genuine support/opposition from a large number of businesses, often small businesses. 


________________


#### If `comment_type` = "org":


`org_name` = the name of the organization. This column will often be filled in automatically with an algorithm's best guess. Please revise these names to be the clearest, standardized, and unique version of the organization's name. 


If more than one organization signed the comment, try to pick the main organizer (e.g., the one whose letterhead is used). If unclear, go with an organization we have seen before (this will increase the chances it is linked to the right set of lobbying coalitions). If still unclear, go with the first signatory. When more than one organization signed the comment, add "; coalition" to the end of whatever `org_type` codes you give it. 


`org_type` = the type of organization, "corp"/"corp group"/"gov"/"ngo" etc. (create additional codes as needed). Definitions:    


- "corp" = individual business (add subtypes as applicable, corp;small business, corp;coop, corp;law firm, corp;bank; corp;financial firm, corp;consultancy)  
- "corp group" = “business interests” (members or representatives of a trade association, corp group;trade association)
- "gov" = government interests ("gov;state" "gov;local" "gov;federal" "gov;tribal"   'gov;regional" or "gov;foreign") within the United States. If states (e.g. Governors or Attorneys Governor), list out all states in org_name.   
- "ngo" = non-business and non-government interests.  
Use a semicolon to indicate   subtypes, such as:   
        "ngo;advocacy"  
        "ngo;legal"  
        ngo;professional (e.g. an association of doctors or other professionals)   
        "ngo;philanthropy"  
"ngo;Foundations
        "ngo;union"  
        "ngo;credit union"  
        ngo;pressure group (a group mobilizes pressure campaigns)  
        "ngo;membership organization" (an NGOs that has members)  
        "ngo;university"   
        "ngo;thinktank" (an organization that does policy-oriented research)  
"ngo;church"   or 
          "ngo;religious"
  - "ngo;ej" Does this organization represent an Environmental Justice/frontline community? I.e. are they based in an affected community? 
<!--see description of "second-order representation" here-->


NOTE: There are many additional sub-types of non-governmental organizations, including advocacy groups, membership groups, professional associations, foundations, and charities. These are not mutually exclusive. Use a semicolon to separate multiple tags.
Some 501c3s are industry associations; they should be coded as a "corp group." However, many NGOs that are not clearly a corp group still advocated for private interests. For example, Chambers of Commerce represents business interests generally and thus ends up being a member of many private-interest coalitions, even though they may not explicitly be commenting on behalf of a regulated industry as an industry association would. 


- "other" = If the commenter is really in no way in any of the above (e.g. a foreign government)


`ask` =   
The text of the comment (e.g., a sentence) that best captures the overall ask, proceeded by a word or two describing the ask (e.g. "ej analysis; [TEXT]" or "exempt credit unions; [TEXT]" ). Specific guidance for EJ asks: EJ asks may be specific-placed based requests or general asks broadly relevant to EJ ("ej specific;" vs. "ej general;"). Because this is federal policy, general assertions are more common, but EJ claims also often make claims about specific groups deserving protection. 


`ask1`, `ask2`, `ask3` =  
The text of the comment's top three (if there are three) specific asks or objections (e.g., the proposed rule text they object to or would like to be changed.) If a comment responds to several issues within a rule, try to select the main ask from each of the top 3 issues, not just the first 3 issues they address. For example, if the organization "opposes" or "supports" several proposed changes, but "strongly opposes" or "strongly supports" other proposed changes, that may indicate which issues they care most about. Ultimately, you must put yourself in the organization's shoes, think about their mission and their members, and decide which of the issues they raise are most important to them. Identify the clearest statements of their top 3 aims and include all surrounding text that is on topic for that ask. As with `ask` tag each sub-ask with a few words, followed by a semicolon before the text of the ask.


If there is only a general sentiment, `ask1` can be the same `ask` (with `ask2` and `ask3` left blank, as they are any time there is not more than one detailed request).


`success`, `success1`, `success2`, `success3` (corresponding to `ask`, `ask1`, `ask2`, `ask3`)


- "2" if, overall, the final rule ended up mostly where requested  
- "1" if, overall, the rule ended somewhat close to that requested  
- "0" if no adverse changes, but also no requests met, or if the request is moot. A request may become moot if superseded by another request. For example, if a group requests that the rule is withdrawn, but if not, changed, then withdrawal makes the requested changes moot. Note: If no changes were requested (they requested the rule be published as is), then no adverse changes is actually a 2)  
- "-1" if the rule ended up somewhat different/opposite than requested  
- "-2" if the rule ended up significantly different/opposite than requested  


Note that "-1" and "-2" can include rules being published without requested changes or withdrawn when the group would prefer the rule not to be withdrawn.


`success_certainty` =    
"1" = fairly certain (may also be left blank), "2" = unsure, "3" = totally unclear


IMPORTANT NOTE: Asks and success should focus on the change from the proposed to the final rule. For example, if an commenter likes a rule, but asks that it goes further, and then the rule is rolled back somewhat, this would be an adverse change and thus a -1. If a rule that an organization liked was withdrawn, it would be a -2. If they ask for it to be published as is and it is published as is, success is a 2. If they ask for it to be strengthened and it is published as is that is a 0. If their asks are a mix of "stay the course" and "strengthen" and the rule is published without change, we might code that a 0 or a 1 depending on how important the changes demanded were. If their main emphasis was on keeping policy provisions in the proposed rule, no change is a moderate success. 


`response` =   
Paste the text of the agency's response to the comment. The `final_url` column contains the link to the final rule (where agencies often respond to some comments) in the federal register. 


________________




#### If `comment_type` = "elected":
Note: this is only for individual elected officials. If a governor or attorney general writes on behalf of the state government that is a "gov" type organization.


`org_name` (or `elected_name`, if your sheet has it) is the official's full name. If there is more than one official, record the first one, unless they are from the US House or Senate, in which case, record all names separated by ";"


`org_type` (or `elected_type`, if your sheet has it) is the official's position. For U.S. Senators and Representatives, this should be "Chamber-[STATE ABBREV]" (e.g. "Senate-WI" or "House-NY"). For state representatives, please start with the state to avoid confusion ("Wisconsin Assembly District 4"). 


Make sure to code `coalition` and `coalition_type`!


The `ask` and `success` variables are coded as described for `comment_type` = "org"


________________


#### If `comment_type` = "mass":
Code `org_name` and `org_type` as the organization mobilizing the comment campaign, if known.


Make sure to code `coalition_comment` and `coalition_type`! Every mass comment must be assigned a coalition!


Keep your eye out for "astroturf" campaigns that appear to advocate for public interest but are really mobilized by private interests. Recall the types of mass comment campaigns from the above description of `comment_type`: 


- "mass;grassroots" = individuals who genuinely care 
- "mass;astroturf" = individuals who were mobilized by a well-resourced group to create an impression of public support/opposition  
And the related `comment_type` if the form letter is signed by businesses rather than individuals: 
- "mass;corp campaign" = genuine support/opposition from a large number of businesses, often small businesses.   


Leave `ask`, `success`, and `response` columns blank.


Check that the `number_of_comments_received` column matches the number of comments/signatures submitted. If it does not, correct it.


If your sheet has a `transparency` column, code whether the campaign was transparent about its   
"sponsor",
"signers",
"both", or
"neither".
If your sheet does not have this column, record transparency comments in the `notes`.


Generally,  it is obvious from the letter who they are and how we might verify that.
A bunch of names with no contact information is not very transparent, but if they say “these are members of our organization,” that should be enough if we needed to verify. Agencies occasionally post one representative comment for a campaign; this should not be held against an organization if they also provided the others, we could get them if needed. 
If a sponsor gives their phone number but not their organization, that is not enough. If you have to research to find the organization's name, that is not transparent. If they submit under a misleading name, that is also not transparent.  I have mostly seen this in corp campaigns, where they try to disguise who paid for the campaign. 


If your sheet has a `platform` column, record the tech platform(s) used to generate comments: "VoterVoice" "Care2" "SalesForce"
If your sheet does not have this column, record any platform used to generate comments in the `notes`.


If your sheet has a `fraud` column, record any indication of fraud, for example, 
- a large number of double-counted signatures
- clear evidence that signers were tricked, paid, or deceived into commenting
- "DMARC validation failed."
Otherwise, leave this column blank.
If your sheet does not have this column, record evidence of fraud in the `notes`.






________________


#### If `comment_type` = "individual":
Only code `position`, `coalition`, `coalition_type`, if it is immediately obvious, otherwise, record comment_type as "individual" and move on. If an individual comment is very technical--perhaps from a professor--do your best to code the coalition and read carefully to see if the person is writing on behalf of a group. "individual" is only for people writing in their personal capacity.

Leave `org_name`, `org_type`, `ask`, and `success` variables blank, unless the individual's organization also submitted comments on behalf of the org, in which case org_name can be helpful for identifying the individual's coalition, but it is not necessary. 
  
