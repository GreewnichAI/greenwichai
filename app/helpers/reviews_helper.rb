module ReviewsHelper
  def get_difference(arr)
	  new_arr = []
    new_arr[0] = diffUtil(arr[0], arr[1])
    new_arr[1] = diffUtil(arr[1], arr[2])
    new_arr[2] = diffUtil(arr[2], arr[3])
    new_arr[3] = diffUtil(arr[3], arr[4])
	  new_arr
	end
	
	def diffUtil(a, b)
    if a < 0 and b < 0
      a.abs - b.abs
    elsif a < 0 and b > 0
      a.abs + b
    else
      b-a
    end
	end
	
	def get_marker_position(val, diff_val, diff, bottom)	  
	  "bottom: #{diff*4.0*diff_val+(val*diff_val)-bottom}px;left:30px;"
	end

  def primary_bm(p_bm)
    if p_bm
      p_bms_with_names = []
      p_bms_in_order = [4274, 4270, 255, 256, 251, 262, 247, 248, 249, 188, 250, 254, 4275, 4276, 4269, 4271, 4273, 4267, 4268, 4263, 4264, 263, 257, 14186, 14168, 14167, 14169, 14166, 246, 14173, 14172, 14170]
      p_bms_in_order.collect do |i| 
        p_bms_with_names << [p_bm[i].f20, i] if p_bm[i]
      end
      p_bms_with_names.compact
    else
      []
    end
  end

  def secondary_bm(s_bm)
    if s_bm
      s_bms_with_names = []    
      s_bms_in_order = [173, 164, 12313, 15635, 15637, 15638, 15639, 205, 15641, 15637, 15638, 5171, 170, 15640, 4274, 4270, 255, 256, 251, 262, 247, 248, 249, 188, 250, 254, 4275, 4276, 4269, 4271, 4273, 4267, 4268, 4263, 4264, 263, 257, 14186, 14168, 14167, 14169, 14166, 246, 14173, 14171, 14172, 14170]
      s_bms_in_order.collect do |i| 
        s_bms_with_names << [s_bm[i].f20, i] if s_bm[i]
      end
      s_bms_with_names.compact
    else
      []
    end    
  end
end
