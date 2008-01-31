def nil.+(o); o; end  
def nil.-(o); o; end  
def nil.*(o); 0; end  
def nil./(o); 0; end  
def nil.**(o); 0; end  
def nil.%(o); 0; end  
def nil.[](o); nil; end  
def nil.length(); 0; end  
def nil.size(); 0; end  
def nil.each(&block);;end  
def nil.<=>(o); o.nil? ? 0 : -1; end
# Behaves like an empty array when pushed
def nil.push(o); [o]; end

# Behaves like an empty string when appended to
def nil.<<(o); o; end

def nil.zero?;true;end